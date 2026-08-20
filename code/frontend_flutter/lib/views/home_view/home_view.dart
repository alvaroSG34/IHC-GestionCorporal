import 'package:flutter/material.dart';

import '../pacientes/paciente_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const PacienteView(),
              ),
            );
          },
          icon: const Icon(Icons.people_outline),
          label: const Text('Pacientes'),
        ),
      ),
    );
  }
}
