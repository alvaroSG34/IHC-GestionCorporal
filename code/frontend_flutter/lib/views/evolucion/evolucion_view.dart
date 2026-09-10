import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/evolucion.dart';
import '../../models/paciente.dart';
import '../../services/evolucion_service.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/top_app_bar.dart';
import '../home_view/home_view.dart';
import 'evolucion_formatters.dart';
import 'periodo_evolucion_view.dart';

class EvolucionView extends StatefulWidget {
  const EvolucionView({super.key, required this.paciente});

  final Paciente paciente;

  @override
  State<EvolucionView> createState() => _EvolucionViewState();
}

class _EvolucionViewState extends State<EvolucionView> {
  late Future<Map<MetricaEvolucion, Evolucion>> _futuroResumen;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    _futuroResumen = EvolucionService().getResumen(widget.paciente.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            TopAppBar(
              titulo: 'Evoluci\u00f3n',
              alVolver: () => Navigator.pop(context),
            ),
            Expanded(
              child: FutureBuilder<Map<MetricaEvolucion, Evolucion>>(
                future: _futuroResumen,
                builder: (context, estado) {
                  if (estado.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (estado.hasError) {
                    return _EstadoError(
                      alReintentar: () => setState(_recargar),
                    );
                  }
                  return _ContenidoEvolucion(
                    paciente: widget.paciente,
                    resumenes: estado.data!,
                  );
                },
              ),
            ),
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

class _ContenidoEvolucion extends StatelessWidget {
  const _ContenidoEvolucion({required this.paciente, required this.resumenes});

  final Paciente paciente;
  final Map<MetricaEvolucion, Evolucion> resumenes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            paciente.nombre,
            style: const TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: medium,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Resumen de progreso',
            style: figmaCaption.copyWith(color: const Color(0xFF616161)),
          ),
          const SizedBox(height: 24),
          const Text('Resumen', style: _tituloSeccion),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: blanco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: MetricaEvolucion.values
                  .map(
                    (metrica) => Padding(
                      padding: EdgeInsets.only(
                        bottom: metrica == MetricaEvolucion.masaMuscular
                            ? 0
                            : 10,
                      ),
                      child: _FilaResumen(
                        metrica: metrica,
                        evolucion: resumenes[metrica],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Elegir medida', style: _tituloSeccion),
          const SizedBox(height: 10),
          ...MetricaEvolucion.values.map(
            (metrica) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TarjetaMetrica(
                metrica: metrica,
                alTocar: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PeriodoEvolucionView(
                      paciente: paciente,
                      metrica: metrica,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  const _FilaResumen({required this.metrica, required this.evolucion});

  final MetricaEvolucion metrica;
  final Evolucion? evolucion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            metrica.etiqueta,
            style: figmaCaption.copyWith(color: const Color(0xFF616161)),
          ),
        ),
        Text(
          evolucion == null
              ? 'Sin datos'
              : formatearRango(evolucion!.resumen, evolucion!.unidad),
          style: const TextStyle(
            color: Color(0xFF2E2E2E),
            fontFamily: semibold,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  const _TarjetaMetrica({required this.metrica, required this.alTocar});

  final MetricaEvolucion metrica;
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metrica.etiqueta,
                      style: const TextStyle(
                        color: Color(0xFF2E2E2E),
                        fontFamily: semibold,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ver gr\u00e1fico de evoluci\u00f3n',
                      style: figmaCaption.copyWith(
                        color: const Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '\u203a',
                style: TextStyle(
                  color: Color(0xFF616161),
                  fontFamily: regular,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoError extends StatelessWidget {
  const _EstadoError({required this.alReintentar});

  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No se pudo cargar la evoluci\u00f3n.',
              textAlign: TextAlign.center,
              style: figmaBody,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: alReintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

const _tituloSeccion = TextStyle(
  color: Color(0xFF2E2E2E),
  fontFamily: medium,
  fontSize: 18,
  fontWeight: FontWeight.w500,
);
