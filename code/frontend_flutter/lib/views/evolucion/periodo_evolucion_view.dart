import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/evolucion.dart';
import '../../models/paciente.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/top_app_bar.dart';
import '../home_view/home_view.dart';
import 'evolucion_formatters.dart';
import 'grafico_evolucion_view.dart';

class PeriodoEvolucionView extends StatefulWidget {
  const PeriodoEvolucionView({
    super.key,
    required this.paciente,
    required this.metrica,
    this.periodoInicial = PeriodoEvolucion.ultimas3,
    this.desdeInicial,
    this.hastaInicial,
  });

  final Paciente paciente;
  final MetricaEvolucion metrica;
  final PeriodoEvolucion periodoInicial;
  final DateTime? desdeInicial;
  final DateTime? hastaInicial;

  @override
  State<PeriodoEvolucionView> createState() => _PeriodoEvolucionViewState();
}

class _PeriodoEvolucionViewState extends State<PeriodoEvolucionView> {
  late PeriodoEvolucion _periodo;
  DateTime? _desde;
  DateTime? _hasta;

  @override
  void initState() {
    super.initState();
    _periodo = widget.periodoInicial;
    _desde = widget.desdeInicial;
    _hasta = widget.hastaInicial;
  }

  Future<void> _seleccionarFecha({required bool esDesde}) async {
    final fechaActual = esDesde ? _desde : _hasta;
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaActual ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (fecha == null || !mounted) return;

    setState(() {
      _periodo = PeriodoEvolucion.personalizado;
      if (esDesde) {
        _desde = fecha;
      } else {
        _hasta = fecha;
      }
    });
  }

  void _verGrafico() {
    if (_periodo == PeriodoEvolucion.personalizado &&
        (_desde == null || _hasta == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona las dos fechas del rango.')),
      );
      return;
    }
    if (_desde != null && _hasta != null && _desde!.isAfter(_hasta!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha desde debe ser anterior a hasta.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GraficoEvolucionView(
          paciente: widget.paciente,
          metrica: widget.metrica,
          periodo: _periodo,
          desde: _periodo == PeriodoEvolucion.personalizado ? _desde : null,
          hasta: _periodo == PeriodoEvolucion.personalizado ? _hasta : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodos = [
      PeriodoEvolucion.ultimas3,
      PeriodoEvolucion.ultimoMes,
      PeriodoEvolucion.ultimos3Meses,
      PeriodoEvolucion.todoHistorial,
    ];

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            TopAppBar(
              titulo: 'Per\u00edodo',
              alVolver: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 24, 30, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.paciente.nombre, style: _nombrePaciente),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.metrica.etiqueta} \u00b7 Selecciona el per\u00edodo',
                      style: figmaCaption.copyWith(
                        color: const Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Elegir per\u00edodo', style: _tituloPeriodo),
                    const SizedBox(height: 10),
                    ...periodos.map(
                      (periodo) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _OpcionPeriodo(
                          periodo: periodo,
                          seleccionada: _periodo == periodo,
                          alTocar: () => setState(() => _periodo = periodo),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Rango personalizado', style: _tituloPeriodo),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SelectorFecha(
                            etiqueta: 'Desde',
                            fecha: _desde,
                            alTocar: () => _seleccionarFecha(esDesde: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SelectorFecha(
                            etiqueta: 'Hasta',
                            fecha: _hasta,
                            alTocar: () => _seleccionarFecha(esDesde: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: Material(
                        color: auxiliar,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _verGrafico,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Text(
                              'Ver gr\u00e1fico',
                              style: figmaButton.copyWith(color: primario),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BarraInferior(
              indiceSeleccionado: 1,
              alCambiar: (indice) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => HomeView(indiceInicial: indice),
                  ),
                  (ruta) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionPeriodo extends StatelessWidget {
  const _OpcionPeriodo({
    required this.periodo,
    required this.seleccionada,
    required this.alTocar,
  });

  final PeriodoEvolucion periodo;
  final bool seleccionada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionada ? const Color(0x38DCEB56) : blanco,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionada ? auxiliar : const Color(0xFFE0E0E0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  periodo.etiqueta,
                  style: TextStyle(
                    color: const Color(0xFF2E2E2E),
                    fontFamily: seleccionada ? semibold : regular,
                    fontSize: 15,
                    fontWeight: seleccionada
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              Text(
                seleccionada ? '\u25cf' : '\u25cb',
                style: TextStyle(
                  color: seleccionada ? primario : const Color(0xFF616161),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectorFecha extends StatelessWidget {
  const _SelectorFecha({
    required this.etiqueta,
    required this.fecha,
    required this.alTocar,
  });

  final String etiqueta;
  final DateTime? fecha;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: blanco,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(
                  color: Color(0xFF616161),
                  fontFamily: regular,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                fecha == null ? 'Seleccionar' : formatearFechaCorta(fecha!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2E2E2E),
                  fontFamily: semibold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _nombrePaciente = TextStyle(
  color: Color(0xFF2E2E2E),
  fontFamily: medium,
  fontSize: 22,
  fontWeight: FontWeight.w500,
);

const _tituloPeriodo = TextStyle(
  color: Color(0xFF2E2E2E),
  fontFamily: medium,
  fontSize: 18,
  fontWeight: FontWeight.w500,
);
