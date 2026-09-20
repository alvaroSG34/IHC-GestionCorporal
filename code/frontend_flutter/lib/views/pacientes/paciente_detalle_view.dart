import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/paciente.dart';
import '../../services/paciente_service.dart';
import '../../widgets/barra_inferior.dart';
import '../dietas/dieta_view.dart';
import '../evaluaciones/evaluacion.view.dart';
import '../evolucion/evolucion_view.dart';
import '../home_view/home_view.dart';
import 'paciente_edit_view.dart';

class PacienteDetalleView extends StatelessWidget {
  const PacienteDetalleView({super.key, required this.paciente});
  final Paciente paciente;

  int _edad() {
    final h = DateTime.now();
    final n = paciente.fechaNacimiento;
    final cumple = DateTime(h.year, n.month, n.day);
    return h.year - n.year - (h.isBefore(cumple) ? 1 : 0);
  }

  String _sexo() {
    if (paciente.sexo.toUpperCase() == 'M') return 'Masculino';
    if (paciente.sexo.toUpperCase() == 'F') return 'Femenino';
    return paciente.sexo;
  }

  String _inicial() {
    final n = paciente.nombre.trim();
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            _header(context),
            Expanded(child: _body(context)),
            BarraInferior(
              indiceSeleccionado: 1,
              alCambiar: (i) {
                if (i == 1) return Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => HomeView(indiceInicial: i)),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

  Widget _header(BuildContext context) => SizedBox(
    height: 72,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Volver',
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 18,
                height: 48,
                child: Center(
                  child: Text(
                    '‹',
                    style: TextStyle(
                      color: Color(0xFF142112),
                      fontFamily: regular,
                      fontSize: 32,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Paciente',
              style: TextStyle(
                color: Color(0xFF142112),
                fontFamily: bold,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => PacienteEditView(paciente: paciente),
                ),
              );
              if (ok == true && context.mounted) Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: const Text(
              'Editar',
              style: TextStyle(
                color: Color(0xFF142112),
                fontFamily: medium,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _body(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 192,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCECCF),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _inicial(),
                  style: const TextStyle(
                    color: Color(0xFF142112),
                    fontFamily: bold,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                paciente.nombre,
                style: const TextStyle(
                  color: Color(0xFF142112),
                  fontFamily: bold,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_edad()} años · ${_sexo()}',
                style: const TextStyle(
                  color: Color(0xFF666B63),
                  fontFamily: regular,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _metrics(),
        const SizedBox(height: 20),
        _action(
          context,
          Icons.assignment_turned_in_outlined,
          'Evaluaciones',
          'Ver historial y mediciones',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EvaluacionView(paciente: paciente),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _action(
          context,
          Icons.show_chart,
          'Evolución',
          'Sigue su progreso',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EvolucionView(paciente: paciente),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _action(
          context,
          Icons.restaurant_outlined,
          'Plan alimenticio',
          'Consulta su plan activo',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DietaView(paciente: paciente)),
          ),
        ),
      ],
    ),
  );

  Widget _metrics() => FutureBuilder<Map<String, dynamic>?>(
    future: PacienteService().getUltimaEvaluacion(paciente.id),
    builder: (_, snapshot) {
      final e = snapshot.data;
      final a = _metros(e?['altura']);
      final p = _num(e?['peso']);
      final i = _num(e?['imc']);
      return Container(
        height: 108,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: superficie,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(46, 46, 31, .08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _metric('Altura', '${_format(a, 2)} m'),
            _metric('Peso', '${_format(p, 1)} kg'),
            _metric('IMC', _format(i, 1)),
          ],
        ),
      );
    },
  );

  Widget _metric(String label, String value) => Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666B63),
            fontFamily: semibold,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: primario,
            fontFamily: bold,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _action(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => Material(
    color: superficie,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(46, 46, 31, .07),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFDCECCF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF142112), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF142112),
                      fontFamily: bold,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF666B63),
                      fontFamily: regular,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '›',
              style: TextStyle(
                color: Color(0xFF666B63),
                fontFamily: regular,
                fontSize: 30,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  double? _num(dynamic v) => v is num
      ? v.toDouble()
      : double.tryParse(v?.toString().replaceAll(',', '.') ?? '');
  double? _metros(dynamic v) {
    final h = _num(v);
    return h == null
        ? null
        : h > 3
        ? h / 100
        : h;
  }

  String _format(double? v, int decimals) =>
      v == null ? '-' : v.toStringAsFixed(decimals).replaceAll('.', ',');
}
