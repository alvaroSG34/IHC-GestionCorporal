import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/paciente.dart';
import '../../services/paciente_service.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/top_app_bar.dart';
import '../evaluaciones/evaluacion.view.dart';

class PacienteDetalleView extends StatelessWidget {
  const PacienteDetalleView({super.key, required this.paciente});

  final Paciente paciente;

  int _calcularEdad() {
    final hoy = DateTime.now();
    final nacimiento = paciente.fechaNacimiento;
    final cumpleEsteAnio = DateTime(hoy.year, nacimiento.month, nacimiento.day);
    return hoy.year - nacimiento.year - (hoy.isBefore(cumpleEsteAnio) ? 1 : 0);
  }

  String _mostrarSexo() {
    if (paciente.sexo.toUpperCase() == 'M') return 'Masculino';
    if (paciente.sexo.toUpperCase() == 'F') return 'Femenino';
    return paciente.sexo;
  }

  String _inicialPaciente() {
    final nombre = paciente.nombre.trim();
    return nombre.isEmpty ? '?' : nombre[0].toUpperCase();
  }

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
              TopAppBar(
                alVolver: () => Navigator.pop(context),
                textoAccion: 'Editar',
                alAccion: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edición de paciente pendiente'),
                    ),
                  );
                },
              ),
              Expanded(child: _contenido(context)),
              BarraInferior(
                indiceSeleccionado: 1,
                alCambiar: (indice) {
                  if (indice == 1) Navigator.pop(context);
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 90,
              height: 90,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              child: Text(
                _inicialPaciente(),
                style: const TextStyle(
                  color: Color(0xFF2E2E2E),
                  fontFamily: semibold,
                  fontSize: 32,
                  height: 40 / 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            paciente.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 20,
              height: 28 / 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_calcularEdad()} años · ${_mostrarSexo()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF616161),
              fontFamily: regular,
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Resumen corporal',
            style: TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 16),
          _resumenMedidas(),
          const SizedBox(height: 24),
          _accesoEvaluaciones(context),
        ],
      ),
    );
  }

  Widget _accesoEvaluaciones(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EvaluacionView(paciente: paciente),
            ),
          );
        },
        child: const SizedBox(
          height: 80,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ver evaluaciones',
                        style: TextStyle(
                          color: Color(0xFF2E2E2E),
                          fontFamily: semibold,
                          fontSize: 16,
                          height: 24 / 16,
                        ),
                      ),
                      Text(
                        'Historial y evolución',
                        style: TextStyle(
                          color: Color(0xFF616161),
                          fontFamily: regular,
                          fontSize: 14,
                          height: 16 / 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '›',
                  style: TextStyle(
                    color: Color(0xFF616161),
                    fontFamily: regular,
                    fontSize: 24,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resumenMedidas() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: PacienteService().getUltimaEvaluacion(paciente.id),
      builder: (context, estado) {
        final evaluacion = estado.data;
        final peso = _numero(evaluacion?['peso']);
        final altura = _alturaEnMetros(evaluacion?['altura']);
        final imc = _numero(evaluacion?['imc']);

        return Container(
          height: 104,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              _medida('Peso', _formatearNumero(peso, 1), 'kg'),
              _separador(),
              _medida('Altura', _formatearNumero(altura, 2), 'm'),
              _separador(),
              _medida('IMC', _formatearNumero(imc, 1), 'kg/m²'),
            ],
          ),
        );
      },
    );
  }

  Widget _medida(String titulo, String valor, String unidad) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: Color(0xFF616161),
                fontSize: 14,
                height: 16 / 14,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                valor,
                style: const TextStyle(
                  color: Color(0xFF2E2E2E),
                  fontFamily: semibold,
                  fontSize: 20,
                  height: 24 / 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                unidad,
                style: const TextStyle(
                  color: Color(0xFF616161),
                  fontSize: 12,
                  height: 16 / 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _separador() {
    return Container(width: 1, height: 72, color: const Color(0xFFE0E0E0));
  }

  double? _numero(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString().replaceAll(',', '.') ?? '');
  }

  double? _alturaEnMetros(dynamic valor) {
    final altura = _numero(valor);
    if (altura == null) return null;
    return altura > 3 ? altura / 100 : altura;
  }

  String _formatearNumero(double? valor, int decimales) {
    if (valor == null) return '-';
    return valor.toStringAsFixed(decimales).replaceAll('.', ',');
  }
}
