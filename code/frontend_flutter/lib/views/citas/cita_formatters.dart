String fechaCita(DateTime fecha) {
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

String horaCita(DateTime fecha) =>
    '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

String fechaHoraCita(DateTime fecha) =>
    '${fechaCita(fecha)} · ${horaCita(fecha)}';
