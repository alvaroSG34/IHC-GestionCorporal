import 'package:flutter/material.dart';

import '../../models/evaluacion.dart';
import '../../services/evaluacion_service.dart';

class EvaluacionView extends StatefulWidget {
  final int pacienteId;

  const EvaluacionView({super.key, required this.pacienteId});

  @override
  State<EvaluacionView> createState() => _EvaluacionViewState();
}

class _EvaluacionViewState extends State<EvaluacionView> {
  late Future<List<Evaluacion>> _futureEvaluaciones;

  @override
  void initState() {
    super.initState();
    _futureEvaluaciones = EvaluacionService().getEvaluaciones(
      widget.pacienteId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluaciones')),
      body: FutureBuilder<List<Evaluacion>>(
        future: _futureEvaluaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final evaluaciones = snapshot.data ?? [];

          if (evaluaciones.isEmpty) {
            return const Center(
              child: Text('No hay evaluaciones para este paciente'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: evaluaciones.length,
            itemBuilder: (context, index) {
              final evaluacion = evaluaciones[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${evaluacion.id}')),
                  title: Text('Peso: ${evaluacion.peso.toStringAsFixed(1)} kg'),
                  subtitle: Text(
                    'Fecha: ${evaluacion.fechaRegistro.toLocal().toString().split(' ')[0]}\n'
                    'Paciente ID: ${evaluacion.pacienteId}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
