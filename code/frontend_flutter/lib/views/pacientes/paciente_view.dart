import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/paciente.dart';
import '../../services/evaluacion_service.dart';
import '../../services/paciente_service.dart';
import '../../widgets/tarjeta_paciente.dart';
import '../../widgets/top_app_bar.dart';
import 'paciente_detalle_view.dart';
import 'paciente_create_view.dart';

class PacienteView extends StatefulWidget {
  const PacienteView({super.key});

  @override
  State<PacienteView> createState() => _PacienteViewState();
}

class _PacienteViewState extends State<PacienteView> {
  final _controladorBusqueda = TextEditingController();
  Future<List<_PacienteListado>>? _futuroPacientes;
  String _textoBusqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
    _controladorBusqueda.addListener(() {
      setState(() {
        _textoBusqueda = _controladorBusqueda.text.trim().toLowerCase();
      });
    });
  }

  void _cargarPacientes() {
    _futuroPacientes = _obtenerPacientesConEvaluaciones();
  }

  Future<List<_PacienteListado>> _obtenerPacientesConEvaluaciones() async {
    final pacientes = await PacienteService().getPacientes();
    final evaluaciones = await EvaluacionService().getTodasEvaluaciones();
    final ultimasFechas = <int, DateTime>{};

    for (final evaluacion in evaluaciones) {
      final fechaActual = ultimasFechas[evaluacion.pacienteId];
      if (fechaActual == null ||
          evaluacion.fechaRegistro.isAfter(fechaActual)) {
        ultimasFechas[evaluacion.pacienteId] = evaluacion.fechaRegistro;
      }
    }

    return pacientes
        .map(
          (paciente) => _PacienteListado(
            paciente: paciente,
            fechaUltimaEvaluacion: ultimasFechas[paciente.id],
          ),
        )
        .toList();
  }

  Future<void> _crearPaciente() async {
    final pacienteCreado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PacienteCreateView()),
    );

    if (pacienteCreado == true && mounted) {
      setState(_cargarPacientes);
    }
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      child: Column(
        children: [
          TopAppBar(
            titulo: 'Pacientes',
            alAccion: _crearPaciente,
            altura: 80,
            tamanoTitulo: 28,
            diametroAccionCircular: 48,
            elevacionAccionCircular: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<_PacienteListado>>(
                      future: _futuroPacientes,
                      builder: (contexto, estado) {
                        if (estado.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (estado.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar pacientes:\n${estado.error}',
                              textAlign: TextAlign.center,
                              style: figmaCaption.copyWith(color: plomo),
                            ),
                          );
                        }

                        final pacientes = (estado.data ?? [])
                            .where(
                              (item) => item.paciente.nombre
                                  .toLowerCase()
                                  .contains(_textoBusqueda),
                            )
                            .toList();

                        if (pacientes.isEmpty) {
                          return Center(
                            child: Text(
                              _textoBusqueda.isEmpty
                                  ? '0 Pacientes'
                                  : 'No se encontraron pacientes',
                              style: figmaCaption.copyWith(color: plomo),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 46,
                              child: TextField(
                                controller: _controladorBusqueda,
                                style: figmaCaption.copyWith(
                                  fontSize: 18,
                                  color: textoSecundario,
                                ),
                                decoration: _decoracionBusqueda(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tus pacientes · ${pacientes.length}',
                              style: const TextStyle(
                                color: Color(0xFF304529),
                                fontFamily: semibold,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 26 / 20,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: pacientes.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (contexto, indice) {
                                  final item = pacientes[indice];
                                  final paciente = item.paciente;
                                  return TarjetaPaciente(
                                    nombre: paciente.nombre,
                                    subtitulo: _textoUltimaEvaluacion(
                                      item.fechaUltimaEvaluacion,
                                    ),
                                    alTocar: () async {
                                      final actualizado =
                                          await Navigator.push<bool>(
                                            contexto,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PacienteDetalleView(
                                                    paciente: paciente,
                                                  ),
                                            ),
                                          );
                                      if (actualizado == true && mounted) {
                                        setState(_cargarPacientes);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoracionBusqueda() => InputDecoration(
    hintText: 'Buscar paciente',
    hintStyle: figmaCaption.copyWith(
      color: const Color(0xFF6B6B66),
      fontSize: 18,
    ),
    prefixIcon: const Icon(Icons.search, color: Color(0xFF4F634A), size: 20),
    prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 46),
    isDense: true,
    filled: true,
    fillColor: superficie,
    border: _bordeBusqueda(const Color(0xFFE3DDD1)),
    enabledBorder: _bordeBusqueda(const Color(0xFFE3DDD1)),
    focusedBorder: _bordeBusqueda(primario),
    contentPadding: const EdgeInsets.symmetric(vertical: 8),
  );

  OutlineInputBorder _bordeBusqueda(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color),
  );

  String _textoUltimaEvaluacion(DateTime? fecha) {
    if (fecha == null) return 'Sin evaluaciones aún';

    final fechaLocal = fecha.toLocal();
    final hoy = DateTime.now();
    final esHoy =
        fechaLocal.year == hoy.year &&
        fechaLocal.month == hoy.month &&
        fechaLocal.day == hoy.day;
    if (esHoy) return 'Última evaluación · Hoy';

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
    return 'Última evaluación · ${fechaLocal.day} ${meses[fechaLocal.month - 1]}';
  }
}

class _PacienteListado {
  const _PacienteListado({
    required this.paciente,
    required this.fechaUltimaEvaluacion,
  });

  final Paciente paciente;
  final DateTime? fechaUltimaEvaluacion;
}
