import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/evaluacion.dart';
import '../../models/paciente.dart';
import '../../widgets/barra_inferior.dart';

class EvaluacionDetalleView extends StatelessWidget {
  const EvaluacionDetalleView({
    super.key,
    required this.evaluacion,
    required this.paciente,
  });

  final Evaluacion evaluacion;
  final Paciente paciente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blancoplomizo,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFB),
            border: Border.all(color: const Color(0xFFC7C7C7)),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(child: _contenido(context)),
              BarraInferior(
                indiceSeleccionado: 2,
                alCambiar: (indice) {
                  if (indice == 2) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(17, 15, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 32,
                ),
                icon: const Icon(Icons.chevron_left, size: 32),
                color: const Color(0xFF616161),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              Text(
                'Evaluación',
                style: TextStyle(
                  color: const Color(0xFF2E2E2E),
                  fontFamily: semibold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(_formatearFecha(evaluacion.fechaRegistro), style: _texto()),
          const SizedBox(height: 8),
          Text(
            paciente.nombre,
            style: TextStyle(
              color: const Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 26),
          Text('Mediciones', style: _tituloSeccion()),
          const SizedBox(height: 12),
          _mediciones(),
          const SizedBox(height: 32),
          Text('Observaciones', style: _tituloSeccion()),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(minHeight: 105),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              evaluacion.observacion?.trim().isNotEmpty == true
                  ? evaluacion.observacion!.trim()
                  : 'Sin observaciones',
              style: _texto(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediciones() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _filaMedicion('Peso', evaluacion.peso.toStringAsFixed(1), 'kg'),
          _filaMedicion('Altura', '${evaluacion.altura}', 'cm'),
          _filaMedicion('IMC', _calcularImc(), 'kg/m²'),
          _filaMedicion(
            'Masa muscular',
            evaluacion.masa_muscular.toStringAsFixed(1),
            'kg',
            ultima: true,
          ),
        ],
      ),
    );
  }

  Widget _filaMedicion(
    String nombre,
    String valor,
    String unidad, {
    bool ultima = false,
  }) {
    return Container(
      height: 47,
      decoration: BoxDecoration(
        border: ultima
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFC7C7C7))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(nombre, style: _texto(fontSize: 13))),
          Container(
            width: 80,
            height: 18,
            alignment: Alignment.centerRight,
            child: Text(valor, style: _texto(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 31, child: Text(unidad, style: _texto(fontSize: 11))),
        ],
      ),
    );
  }

  String _calcularImc() {
    final alturaEnMetros = evaluacion.altura / 100;
    if (alturaEnMetros <= 0) return '-';
    return (evaluacion.peso / (alturaEnMetros * alturaEnMetros))
        .toStringAsFixed(2);
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  TextStyle _texto({double fontSize = 14}) {
    return TextStyle(color: const Color(0xFF616161), fontSize: fontSize);
  }

  TextStyle _tituloSeccion() {
    return TextStyle(
      color: const Color(0xFF2E2E2E),
      fontFamily: semibold,
      fontSize: 18,
    );
  }
}
