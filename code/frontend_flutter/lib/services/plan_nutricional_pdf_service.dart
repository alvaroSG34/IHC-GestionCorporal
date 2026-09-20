import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/comidas_dia.dart';
import '../models/dieta.dart';
import '../models/paciente.dart';

/// Compone y presenta el PDF de una dieta ya cargada.
class PlanNutricionalPdfService {
  const PlanNutricionalPdfService._();

  static Future<void> mostrarVistaPrevia({
    required Paciente paciente,
    required Dieta dieta,
    required List<ComidasDia> planSemanal,
  }) => Printing.layoutPdf(
    name: 'plan_nutricional_${_nombreArchivo(paciente.nombre)}.pdf',
    onLayout: (_) => construirPdf(
      paciente: paciente,
      dieta: dieta,
      planSemanal: planSemanal,
    ),
  );

  static Future<Uint8List> construirPdf({
    required Paciente paciente,
    required Dieta dieta,
    required List<ComidasDia> planSemanal,
  }) async {
    final documento = pw.Document();
    final porDia = {for (final dia in planSemanal) dia.diaSemana: dia};
    final fuenteRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Kreon-Regular.ttf'),
    );
    final fuenteBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Kreon-Bold.ttf'),
    );

    documento.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          theme: pw.ThemeData.withFont(
            base: fuenteRegular,
            bold: fuenteBold,
          ),
        ),
        build: (_) => [
          _encabezado(paciente, dieta),
          pw.SizedBox(height: 20),
          ..._dias.map((dia) => _seccionDia(dia, porDia[dia.api])),
        ],
      ),
    );
    return documento.save();
  }

  static pw.Widget _encabezado(Paciente paciente, Dieta dieta) => pw.Container(
    padding: const pw.EdgeInsets.all(18),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0xfff7f1e9),
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PLAN NUTRICIONAL',
          style: pw.TextStyle(
            fontSize: 21,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xff313a1d),
          ),
        ),
        pw.SizedBox(height: 12),
        _dato('Paciente', paciente.nombre),
        _dato('Fecha de inicio', _formatearFecha(dieta.fechaInicio)),
        pw.SizedBox(height: 10),
        pw.Text(
          'RESUMEN DEL PLAN',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
        pw.SizedBox(height: 5),
        _dato('Dieta', dieta.nombre),
        _dato('Objetivo', dieta.objetivo),
        _dato('Meta diaria', '${_formatearCalorias(dieta.caloriasDiarias)} kcal'),
      ],
    ),
  );

  static pw.Widget _dato(String etiqueta, String valor) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$etiqueta: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TextSpan(text: valor),
        ],
      ),
    ),
  );

  static pw.Widget _seccionDia(_DiaPdf dia, ComidasDia? comidas) {
    final desayuno = comidas?.desayuno;
    final almuerzo = comidas?.almuerzo;
    final cena = comidas?.cena;
    final total = (desayuno?.totalCalorias ?? 0) +
        (almuerzo?.totalCalorias ?? 0) +
        (cena?.totalCalorias ?? 0);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xffc2c2ba)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                dia.nombre.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xff313a1d),
                ),
              ),
              pw.Text(
                'Total: ${_formatearCalorias(total)} kcal',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          _bloqueComida('Desayuno', desayuno),
          _bloqueComida('Almuerzo', almuerzo),
          _bloqueComida('Cena', cena),
        ],
      ),
    );
  }

  static pw.Widget _bloqueComida(String titulo, Comida? comida) {
    final alimentos = comida?.alimentos ?? const <Alimento>[];
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titulo, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          if (alimentos.isEmpty)
            pw.Text(
              'Sin alimentos registrados',
              style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
            )
          else ...[
            ...alimentos.map(
              (alimento) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Text(
                  '• ${alimento.nombre} — ${alimento.porcion} — '
                  '${_formatearCalorias(alimento.calorias)} kcal',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Subtotal: ${_formatearCalorias(comida!.totalCalorias)} kcal',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  static String _formatearCalorias(int calorias) => calorias
      .toString()
      .replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => '.');

  static String _nombreArchivo(String nombre) => nombre
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

class _DiaPdf {
  const _DiaPdf(this.api, this.nombre);

  final String api;
  final String nombre;
}

const _dias = [
  _DiaPdf('lunes', 'Lunes'),
  _DiaPdf('martes', 'Martes'),
  _DiaPdf('miercoles', 'Miércoles'),
  _DiaPdf('jueves', 'Jueves'),
  _DiaPdf('viernes', 'Viernes'),
  _DiaPdf('sabado', 'Sábado'),
  _DiaPdf('domingo', 'Domingo'),
];
