import '../../models/evolucion.dart';

String formatearValor(double? valor, String unidad) {
  if (valor == null) return 'Sin datos';
  return '${formatearNumero(valor)} $unidad';
}

String formatearNumero(double valor) {
  return valor
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '')
      .replaceAll('.', ',');
}

String formatearRango(ResumenEvolucion resumen, String unidad) {
  if (resumen.valorInicial == null || resumen.valorActual == null) {
    return 'Sin datos';
  }
  return '${formatearValor(resumen.valorInicial, unidad)} \u2192 ${formatearValor(resumen.valorActual, unidad)}';
}

String formatearFechaCorta(DateTime fecha) {
  const meses = [
    'ene.',
    'feb.',
    'mar.',
    'abr.',
    'may.',
    'jun.',
    'jul.',
    'ago.',
    'sep.',
    'oct.',
    'nov.',
    'dic.',
  ];
  return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
}

String formatearEtiquetaEje(DateTime fecha) {
  const meses = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];
  return '${fecha.day} ${meses[fecha.month - 1]}';
}
