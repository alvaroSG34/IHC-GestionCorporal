import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/paciente.dart';
import '../../widgets/barra_inferior.dart';
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
      padding: const EdgeInsets.fromLTRB(23, 16, 23, 24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 24, height: 32),
              icon: const Icon(Icons.chevron_left, size: 32),
              color: const Color(0xFF616161),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0E0E0),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            paciente.nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${_calcularEdad()} años',
            style: const TextStyle(color: Color(0xFF616161), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            _mostrarSexo(),
            style: const TextStyle(color: Color(0xFF616161), fontSize: 14),
          ),
          const SizedBox(height: 29),
          _resumenMedidas(),
          const SizedBox(height: 72),
          SizedBox(
            width: double.infinity,
            height: 72,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EvaluacionView(paciente: paciente),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0E0E0),
                foregroundColor: const Color(0xFF616161),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Ver evaluaciones',
                style: TextStyle(fontFamily: semibold, fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumenMedidas() {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _medida('Peso', '70', 'kg'),
          _separador(),
          _medida('Altura', '170', 'cm'),
          _separador(),
          _medida('IMC', '24.2', 'kg/m²'),
        ],
      ),
    );
  }

  Widget _medida(String titulo, String valor, String unidad) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(color: Color(0xFF616161), fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              height: 18,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(3),
              ),
              alignment: Alignment.center,
              child: Text(
                valor,
                style: const TextStyle(color: Color(0xFF616161), fontSize: 12),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.center,
              child: Text(
                unidad,
                style: const TextStyle(color: Color(0xFF616161), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _separador() {
    return Container(width: 1, height: 74, color: const Color(0xFFC7C7C7));
  }
}
