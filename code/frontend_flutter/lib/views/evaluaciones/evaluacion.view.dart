import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/evaluacion.dart';
import '../../models/paciente.dart';
import '../../services/evaluacion_service.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/tarjeta_evaluacion.dart';
import '../../widgets/top_app_bar.dart';
import '../home_view/home_view.dart';
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
                indiceSeleccionado: 1,
                alCambiar: (indice) {
                  if (indice == 1) {
                    Navigator.pop(context);
                    return;
                  }
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => HomeView(indiceInicial: indice),
                    ),
                    (route) => false,
                  );
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

                final evaluaciones = [...(estado.data ?? [])]
                  ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
                if (evaluaciones.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay evaluaciones para este paciente',
                      style: TextStyle(color: plomo, fontFamily: regular),
                    ),
                  );
                }

                final ultima = evaluaciones.first;
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  itemCount: evaluaciones.length + 2,
                  separatorBuilder: (_, indice) =>
                      SizedBox(height: indice == 0 ? 16 : 5),
                  itemBuilder: (contexto, indice) {
                    if (indice == 0) {
                      return _ResumenUltimaEvaluacion(
                        fecha: _formatearFechaHora(ultima.fechaRegistro),
                      );
                    }
                    if (indice == 1) {
                      return _EncabezadoHistorial(total: evaluaciones.length);
                    }

                    final evaluacion = evaluaciones[indice - 2];
                    return TarjetaEvaluacion(
                      numero: '${evaluacion.nro_evaluacion}',
                      texto: _formatearFechaHora(evaluacion.fechaRegistro),
                      alTocar: () => _abrirDetalle(evaluacion),
                    );
                  },
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

class _ResumenUltimaEvaluacion extends StatelessWidget {
  const _ResumenUltimaEvaluacion({required this.fecha});

  final String fecha;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF0D1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Última evaluación',
            style: TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 14,
              height: 17 / 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  fecha,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: figmaBody.copyWith(
                    color: const Color(0xFF2E2E2E),
                    fontSize: 22,
                    height: 28 / 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E8BA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('●', style: TextStyle(color: primario, fontSize: 10)),
                    SizedBox(width: 8),
                    Text(
                      'Seguimiento',
                      style: TextStyle(
                        color: Color(0xFF2E2E2E),
                        fontSize: 13,
                        height: 16 / 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EncabezadoHistorial extends StatelessWidget {
  const _EncabezadoHistorial({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Historial de evaluaciones',
              style: TextStyle(
                color: Color(0xFF2E2E2E),
                fontFamily: semibold,
                fontSize: 16,
                height: 24 / 16,
              ),
            ),
          ),
          Text(
            '$total ${total == 1 ? 'registro' : 'registros'}',
            style: const TextStyle(
              color: Color(0xFF666B63),
              fontSize: 13,
              height: 16 / 13,
            ),
          ),
        ],
      ),
    );
  }
}
