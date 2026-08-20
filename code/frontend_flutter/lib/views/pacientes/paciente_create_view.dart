import 'package:flutter/material.dart';

import '../../services/paciente_service.dart';

class PacienteCreateView extends StatefulWidget {
  const PacienteCreateView({super.key});

  @override
  State<PacienteCreateView> createState() => _PacienteCreateViewState();
}

class _PacienteCreateViewState extends State<PacienteCreateView> {
  final nombre = TextEditingController();
  final telefono = TextEditingController();
  final fecha = TextEditingController();

  String sexo = 'M';

  Future<void> guardarPaciente() async {
    if (nombre.text.isEmpty || fecha.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Completa nombre y fecha')));
      return;
    }

    final fechaNacimiento = DateTime.tryParse(fecha.text);

    if (fechaNacimiento == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('fecha invalida')));
      return;
    }

    try {
      await PacienteService().createPaciente(
        nombre: nombre.text,
        sexo: sexo,
        fechaNacimiento: fechaNacimiento,
        telefono: telefono.text.isEmpty ? null : telefono.text,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    nombre.dispose();
    telefono.dispose();
    fecha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo paciente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),

            const SizedBox(height: 16),

            DropdownButton<String>(
              value: sexo,
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Masculino')),
                DropdownMenuItem(value: 'F', child: Text('Femenino')),
              ],
              onChanged: (valor) {
                setState(() {
                  sexo = valor!;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: fecha,
              decoration: const InputDecoration(
                labelText: 'Fecha (yyyy-MM-dd)',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: telefono,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: guardarPaciente,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
