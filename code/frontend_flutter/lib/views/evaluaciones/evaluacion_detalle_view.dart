import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/evaluacion.dart';
import '../../models/paciente.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/top_app_bar.dart';
import 'evaluacion_edit_view.dart';

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
              TopAppBar(
                titulo: 'Evaluación',
                alVolver: () => Navigator.pop(context),
                textoAccion: 'Editar',
                alAccion: () async {
                  final actualizado = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EvaluacionEditView(
                        evaluacion: evaluacion,
                        paciente: paciente,
                      ),
                    ),
                  );
                  if (actualizado == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              Expanded(child: _contenido()),
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

  Widget _contenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 15),
          Text(
            paciente.nombre,
            style: const TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Evaluación ${evaluacion.nro_evaluacion} · ${_formatearFecha(evaluacion.fechaRegistro)}',
            style: const TextStyle(
              color: Color(0xFF616161),
              fontFamily: regular,
              fontSize: 14,
              height: 24 / 14,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mediciones',
            style: TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 8),
          _mediciones(),
          const SizedBox(height: 16),
          const Text(
            'Observación',
            style: TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 8),
          _observacion(),
        ],
      ),
    );
  }

  Widget _mediciones() {
    return Container(
      height: 208,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _filaMedicion('Peso', '${_numero(evaluacion.peso, 1)} kg'),
          _filaMedicion('Altura', '${_numero(evaluacion.altura / 100, 2)} m'),
          _filaMedicion(
            'Masa muscular',
            '${_numero(evaluacion.masa_muscular, 1)} %',
          ),
          _filaMedicion('IMC', _numero(evaluacion.imc, 1), ultima: true),
        ],
      ),
    );
  }

  Widget _filaMedicion(String etiqueta, String valor, {bool ultima = false}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        border: ultima
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(
                color: Color(0xFF616161),
                fontFamily: regular,
                fontSize: 16,
                height: 24 / 16,
              ),
            ),
          ),
          Text(
            valor,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _observacion() {
    final observacion = evaluacion.observacion?.trim();

    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        observacion?.isNotEmpty == true ? observacion! : 'Sin observaciones',
        style: const TextStyle(
          color: Color(0xFF616161),
          fontFamily: regular,
          fontSize: 15,
          height: 24 / 15,
        ),
      ),
    );
  }

  String _numero(num valor, int decimales) {
    return valor.toStringAsFixed(decimales).replaceAll('.', ',');
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}
