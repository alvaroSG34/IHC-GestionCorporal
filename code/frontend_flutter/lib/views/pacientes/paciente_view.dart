import 'package:flutter/material.dart';

class PacienteView extends StatelessWidget {
  const PacienteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
      ),
      body: const Center(
        child: Text('Lista de pacientes'),
      ),
    );
  }
}
