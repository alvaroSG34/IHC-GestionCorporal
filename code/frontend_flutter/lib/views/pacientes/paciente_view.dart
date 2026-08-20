import 'package:flutter/material.dart';

import '../../models/paciente.dart';
import '../../services/paciente_service.dart';
import 'paciente_create_view.dart';
import '../evaluaciones/evaluacion.view.dart';

class PacienteView extends StatefulWidget {
  const PacienteView({super.key});

  @override
  State<PacienteView> createState() => _PacienteViewState();
}

class _PacienteViewState extends State<PacienteView> {
  final _pacientes = PacienteService().getPacientes();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear paciente',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PacienteCreateView(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Paciente>>(
        future: _pacientes,
        builder: (context, estado) {
          if (estado.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (estado.hasError) {
            return Center(child: Text('Error: ${estado.error}'));
          }

          final pacientes = estado.data ?? [];

          if (pacientes.isEmpty) {
            return const Center(child: Text('0 Pacientes'));
          }

          return ListView.builder(
            itemCount: pacientes.length,
            itemBuilder: (context, i) {
              final paciente = pacientes[i];

              return ListTile(
                title: Text('ID: ${paciente.id}'),
                subtitle: Text(
                  'Nombre: ${paciente.nombre}\n'
                  'Sexo: ${paciente.sexo}\n'
                  'Nacimiento: ${paciente.fechaNacimiento}\n'
                  'Teléfono: ${paciente.telefono ?? 'Sin fono'}',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EvaluacionView(pacienteId: paciente.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
