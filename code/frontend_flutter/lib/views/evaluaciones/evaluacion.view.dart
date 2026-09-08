import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/evaluacion.dart';
import '../../models/paciente.dart';
import '../../services/evaluacion_service.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/tarjeta_evaluacion.dart';
import '../../widgets/top_app_bar.dart';
import 'evaluacion_create_view.dart';
import 'evaluacion_detalle_view.dart';

class EvaluacionView extends StatefulWidget {
  const EvaluacionView({super.key, required this.paciente});

  final Paciente paciente;

  @override
  State<EvaluacionView> createState() => _EvaluacionViewState();
}

class _EvaluacionViewState extends State<EvaluacionView> {
  late Future<List<Evaluacion>> _futuroEvaluaciones;

  @override
  void initState() {
    super.initState();
    _cargarEvaluaciones();
  }

  void _cargarEvaluaciones() {
    _futuroEvaluaciones = EvaluacionService().getEvaluaciones(
      widget.paciente.id,
    );
  }

  Future<void> _abrirCrearEvaluacion() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluacionCreateView(paciente: widget.paciente),
      ),
    );

    if (resultado == true && mounted) setState(_cargarEvaluaciones);
  }

  Future<void> _abrirDetalle(Evaluacion evaluacion) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluacionDetalleView(
          evaluacion: evaluacion,
          paciente: widget.paciente,
        ),
      ),
    );

    if (actualizado == true && mounted) setState(_cargarEvaluaciones);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: const Color(0xFFC7C7C7)),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              TopAppBar(
                titulo: 'Evaluaciones',
                alVolver: () => Navigator.pop(context),
                alAccion: _abrirCrearEvaluacion,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            widget.paciente.nombre,
            style: const TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 23),
          Expanded(
            child: FutureBuilder<List<Evaluacion>>(
              future: _futuroEvaluaciones,
              builder: (contexto, estado) {
                if (estado.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (estado.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar evaluaciones:\n${estado.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: plomo, fontFamily: regular),
                    ),
                  );
                }

                final evaluaciones = estado.data ?? [];
                if (evaluaciones.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay evaluaciones para este paciente',
                      style: TextStyle(color: plomo, fontFamily: regular),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: evaluaciones.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (contexto, indice) => TarjetaEvaluacion(
                    numero: '${evaluaciones[indice].nro_evaluacion}',
                    texto: _formatearFechaHora(
                      evaluaciones[indice].fechaRegistro,
                    ),
                    alTocar: () => _abrirDetalle(evaluaciones[indice]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFechaHora(DateTime fecha) {
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
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year} $hora:$minuto';
  }
}
