import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
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

class GraficoEvolucionView extends StatefulWidget {
  const GraficoEvolucionView({
    super.key,
    required this.paciente,
    required this.metrica,
    required this.periodo,
    this.desde,
    this.hasta,
  });

  final Paciente paciente;
  final MetricaEvolucion metrica;
  final PeriodoEvolucion periodo;
  final DateTime? desde;
  final DateTime? hasta;

  @override
  State<GraficoEvolucionView> createState() => _GraficoEvolucionViewState();
}

class _GraficoEvolucionViewState extends State<GraficoEvolucionView> {
  late Future<Evolucion> _futuro;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    _futuro = EvolucionService().getEvolucion(
      pacienteId: widget.paciente.id,
      metrica: widget.metrica,
      periodo: widget.periodo,
      desde: widget.desde,
      hasta: widget.hasta,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            TopAppBar(
              titulo: 'Gr\u00e1fico',
              alVolver: () => Navigator.pop(context),
            ),
            Expanded(
              child: FutureBuilder<Evolucion>(
                future: _futuro,
                builder: (context, estado) {
                  if (estado.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (estado.hasError) {
                    return _ErrorGrafico(
                      alReintentar: () => setState(_recargar),
                    );
                  }
                  final evolucion = estado.data!;
                  if (evolucion.puntos.isEmpty) {
                    return const _SinDatosGrafico();
                  }
                  return _ContenidoGrafico(evolucion: evolucion);
                },
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

class _ContenidoGrafico extends StatelessWidget {
  const _ContenidoGrafico({required this.evolucion});

  final Evolucion evolucion;

  @override
  Widget build(BuildContext context) {
    final puntos = evolucion.puntos;
    final primerPunto = puntos.first;
    final ultimoPunto = puntos.last;
    final dias = ultimoPunto.fecha.difference(primerPunto.fecha).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${evolucion.paciente.nombre} - ${evolucion.periodo.etiqueta}',
              style: figmaCaption.copyWith(color: Colors.black),
            ),
          ),
          const SizedBox(height: 10),
          _TarjetaGrafico(evolucion: evolucion),
          const SizedBox(height: 12),
          _Historial(evolucion: evolucion),
          const SizedBox(height: 12),
          _TarjetaCambio(
            cambio: evolucion.resumen.cambio,
            unidad: evolucion.unidad,
            dias: dias,
          ),
        ],
      ),
    );
  }
}

class _TarjetaGrafico extends StatelessWidget {
  const _TarjetaGrafico({required this.evolucion});

  final Evolucion evolucion;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 253,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: blanco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x4A000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evoluci\u00f3n ${evolucion.metrica.etiqueta.toLowerCase()}',
            style: const TextStyle(
              color: Colors.black,
              fontFamily: bold,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _LineaEvolucion(evolucion: evolucion)),
        ],
      ),
    );
  }
}

class _LineaEvolucion extends StatelessWidget {
  const _LineaEvolucion({required this.evolucion});

  final Evolucion evolucion;

  @override
  Widget build(BuildContext context) {
    final valores = evolucion.puntos.map((punto) => punto.valor).toList();
    final minimo = valores.reduce(min);
    final maximo = valores.reduce(max);
    final margen = minimo == maximo
        ? max(1, minimo.abs() * 0.1)
        : (maximo - minimo) * 0.2;
    final minY = minimo - margen;
    final maxY = maximo + margen;
    final intervalo = (maxY - minY) / 4;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, right: 24, bottom: 18),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: max(0, evolucion.puntos.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                horizontalInterval: intervalo,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: Color(0xFFE0E0E0), strokeWidth: 1),
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: intervalo,
                    getTitlesWidget: (valor, meta) => Text(
                      formatearNumero(valor),
                      style: const TextStyle(fontFamily: regular, fontSize: 9),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (valor, meta) {
                      final indice = valor.round();
                      if (indice < 0 || indice >= evolucion.puntos.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          formatearEtiquetaEje(evolucion.puntos[indice].fecha),
                          style: const TextStyle(
                            fontFamily: regular,
                            fontSize: 9,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.black54),
                  bottom: BorderSide(color: Colors.black54),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => primario,
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  tooltipMargin: 10,
                  tooltipBorder: const BorderSide(color: auxiliar),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => spots
                      .map(
                        (spot) => LineTooltipItem(
                          formatearValor(spot.y, evolucion.unidad),
                          const TextStyle(
                            color: blanco,
                            fontFamily: semibold,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: evolucion.puntos
                      .asMap()
                      .entries
                      .map(
                        (entrada) =>
                            FlSpot(entrada.key.toDouble(), entrada.value.valor),
                      )
                      .toList(),
                  isCurved: false,
                  color: primario,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 46,
          child: Text(
            evolucion.unidad,
            style: const TextStyle(fontFamily: medium, fontSize: 12),
          ),
        ),
        const Positioned(
          right: 0,
          bottom: 0,
          child: Text(
            'Tiempo',
            style: TextStyle(fontFamily: medium, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _Historial extends StatelessWidget {
  const _Historial({required this.evolucion});

  final Evolucion evolucion;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x30000000)),
      ),
      child: Column(
        children: evolucion.puntos
            .map(
              (punto) => Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: auxiliar,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${punto.numeroEvaluacion}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formatearFechaCorta(punto.fecha),
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: medium,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      formatearValor(punto.valor, evolucion.unidad),
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: medium,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TarjetaCambio extends StatelessWidget {
  const _TarjetaCambio({
    required this.cambio,
    required this.unidad,
    required this.dias,
  });

  final double? cambio;
  final String unidad;
  final int dias;

  @override
  Widget build(BuildContext context) {
    final textoCambio = cambio == null
        ? 'Sin datos suficientes'
        : '${cambio! > 0 ? '+' : ''}${formatearValor(cambio, unidad)}${dias > 0 ? ' en $dias d\u00edas' : ''}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x30000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cambio total',
            style: TextStyle(fontFamily: medium, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(textoCambio, style: figmaCaption),
        ],
      ),
    );
  }
}

class _SinDatosGrafico extends StatelessWidget {
  const _SinDatosGrafico();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No hay evaluaciones para el per\u00edodo seleccionado.',
          textAlign: TextAlign.center,
          style: figmaBody,
        ),
      ),
    );
  }
}

class _ErrorGrafico extends StatelessWidget {
  const _ErrorGrafico({required this.alReintentar});

  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No se pudo cargar el gr\u00e1fico.', style: figmaBody),
          const SizedBox(height: 12),
          TextButton(onPressed: alReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
