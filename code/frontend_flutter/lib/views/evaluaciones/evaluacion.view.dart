import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/evaluacion.dart';
import '../../models/paciente.dart';
import '../../services/evaluacion_service.dart';
import '../../widgets/barra_inferior.dart';
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

    if (resultado == true && mounted) {
      setState(_cargarEvaluaciones);
    }
  }

  void _abrirDetalle(Evaluacion evaluacion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluacionDetalleView(
          evaluacion: evaluacion,
          paciente: widget.paciente,
        ),
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 15, 23, 0),
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
                'Evaluaciones',
                style: TextStyle(
                  color: const Color(0xFF2E2E2E),
                  fontFamily: semibold,
                  fontSize: 23,
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 32,
                ),
                icon: const Icon(Icons.add, size: 28),
                color: const Color(0xFF2E2E2E),
                onPressed: _abrirCrearEvaluacion,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              widget.paciente.nombre,
              style: const TextStyle(color: Color(0xFF616161), fontSize: 13),
            ),
          ),
          const SizedBox(height: 36),
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
                  itemBuilder: (contexto, indice) => _TarjetaEvaluacion(
                    evaluacion: evaluaciones[indice],
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
}

class _TarjetaEvaluacion extends StatelessWidget {
  const _TarjetaEvaluacion({required this.evaluacion, required this.alTocar});

  final Evaluacion evaluacion;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE0E0E0),
              ),
              child: Text(
                '${evaluacion.id}',
                style: const TextStyle(color: Color(0xFF616161), fontSize: 14),
              ),
            ),
            const SizedBox(width: 17),
            Expanded(
              child: Text(
                _formatearFecha(evaluacion.fechaRegistro),
                style: TextStyle(
                  color: const Color(0xFF2E2E2E),
                  fontFamily: semibold,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF616161), size: 28),
          ],
        ),
      ),
    );
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
