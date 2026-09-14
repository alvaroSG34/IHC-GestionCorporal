import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/cita.dart';
import '../../models/paciente.dart';
import '../../services/cita_service.dart';
import '../../services/paciente_service.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';
import 'cita_detalle_view.dart';
import 'cita_formatters.dart';

class CitaFormularioView extends StatefulWidget {
  const CitaFormularioView({super.key, this.cita});

  final Cita? cita;

  @override
  State<CitaFormularioView> createState() => _CitaFormularioViewState();
}

class _CitaFormularioViewState extends State<CitaFormularioView> {
  final _cPaciente = TextEditingController();
  final _cFecha = TextEditingController();
  final _cHora = TextEditingController();
  final _cTipo = TextEditingController();
  final _cObservacion = TextEditingController();
  late Future<List<Paciente>> _futuroPacientes;
  Paciente? _paciente;
  DateTime? _fecha;
  TimeOfDay? _hora;
  bool _guardando = false;
  String? _errorPaciente;
  String? _errorFecha;
  String? _errorHora;
  String? _errorTipo;

  bool get _editando => widget.cita != null;

  @override
  void initState() {
    super.initState();
    _futuroPacientes = _cargarPacientes();
    final cita = widget.cita;
    if (cita != null) {
      _fecha = DateTime(
        cita.fechaHora.year,
        cita.fechaHora.month,
        cita.fechaHora.day,
      );
      _hora = TimeOfDay.fromDateTime(cita.fechaHora);
      _cPaciente.text = cita.paciente.nombre;
      _cFecha.text = fechaCita(_fecha!);
      _cHora.text = horaCita(cita.fechaHora);
      _cTipo.text = cita.tipoConsulta;
      _cObservacion.text = cita.observacion ?? '';
    }
  }

  Future<List<Paciente>> _cargarPacientes() => PacienteService().getPacientes();

  @override
  void dispose() {
    _cPaciente.dispose();
    _cFecha.dispose();
    _cHora.dispose();
    _cTipo.dispose();
    _cObservacion.dispose();
    super.dispose();
  }

  Future<void> _seleccionarPaciente() async {
    final pacientes = await _futuroPacientes;
    if (!mounted) return;
    final elegido = await showModalBottomSheet<Paciente>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: pacientes
              .map(
                (paciente) => ListTile(
                  title: Text(
                    paciente.nombre,
                    style: const TextStyle(fontFamily: medium),
                  ),
                  onTap: () => Navigator.pop(context, paciente),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (elegido != null) {
      setState(() {
        _paciente = elegido;
        _cPaciente.text = elegido.nombre;
        _errorPaciente = null;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final primeraFecha = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaInicial = _fecha != null && !_fecha!.isBefore(primeraFecha)
        ? _fecha!
        : primeraFecha;
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: primeraFecha,
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() {
        _fecha = fecha;
        _cFecha.text = fechaCita(fecha);
        _errorFecha = null;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _hora = hora;
        _cHora.text =
            '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
        _errorHora = null;
      });
    }
  }

  Future<void> _guardar() async {
    final pacienteId = _paciente?.id ?? widget.cita?.paciente.id;
    final nombrePaciente = _cPaciente.text.trim();
    final tipoConsulta = _cTipo.text.trim();
    final ahora = DateTime.now();
    final fechaMinima = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaHora = _fecha != null && _hora != null
        ? DateTime(
            _fecha!.year,
            _fecha!.month,
            _fecha!.day,
            _hora!.hour,
            _hora!.minute,
          )
        : null;
    final soloLetras = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');
    final errorPaciente =
        pacienteId == null ||
            (nombrePaciente.isNotEmpty && !soloLetras.hasMatch(nombrePaciente))
        ? 'Solo se permiten caracteres a-z.'
        : null;
    final errorFecha = _fecha == null || _fecha!.isBefore(fechaMinima)
        ? 'Introduzca una fecha posterior'
        : null;
    final errorHora = fechaHora == null || !fechaHora.isAfter(ahora)
        ? 'Hora invalida o reservada'
        : null;
    final errorTipo = tipoConsulta.isEmpty || !soloLetras.hasMatch(tipoConsulta)
        ? 'Solo se permiten caracteres a-z.'
        : null;

    if (pacienteId == null ||
        _fecha == null ||
        _hora == null ||
        tipoConsulta.isEmpty ||
        errorPaciente != null ||
        errorFecha != null ||
        errorHora != null ||
        errorTipo != null) {
      setState(() {
        _errorPaciente = errorPaciente;
        _errorFecha = errorFecha;
        _errorHora = errorHora;
        _errorTipo = errorTipo;
      });
      return;
    }
    setState(() => _guardando = true);
    try {
      if (_editando) {
        await CitaService().actualizarCita(
          citaId: widget.cita!.id,
          pacienteId: pacienteId,
          fechaHora: fechaHora!,
          tipoConsulta: tipoConsulta,
          observacion: _cObservacion.text,
        );
      } else {
        final citaCreada = await CitaService().crearCita(
          pacienteId: pacienteId,
          fechaHora: fechaHora!,
          tipoConsulta: tipoConsulta,
          observacion: _cObservacion.text,
        );
        if (mounted) {
          await Navigator.of(context).pushReplacement<bool, bool>(
            MaterialPageRoute(
              builder: (_) => CitaDetalleView(cita: citaCreada),
            ),
            result: true,
          );
        }
        return;
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _guardando = false);
        final mensaje = error.toString().replaceFirst('Exception: ', '');
        if (mensaje.contains('Ya existe una cita programada')) {
          setState(() => _errorHora = 'Hora invalida o reservada');
        } else {
          _mensaje(mensaje);
        }
      }
    }
  }

  void _mensaje(String texto) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(texto)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    body: SafeArea(
      child: Column(
        children: [
          TopAppBar(
            titulo: _editando ? 'Editar cita' : 'Nueva cita',
            alVolver: () => Navigator.pop(context),
          ),
          Expanded(
            child: FutureBuilder<List<Paciente>>(
              future: _futuroPacientes,
              builder: (context, estado) {
                if (estado.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (estado.hasError) {
                  return Center(
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _futuroPacientes = _cargarPacientes()),
                      child: const Text('Reintentar pacientes'),
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Input(
                        etiqueta: 'Paciente',
                        controlador: _cPaciente,
                        placeholder: 'Selecciona un paciente',
                        soloLectura: true,
                        alTocar: _seleccionarPaciente,
                        mensajeError: _errorPaciente,
                      ),
                      const SizedBox(height: 16),
                      Input(
                        etiqueta: 'Fecha',
                        controlador: _cFecha,
                        placeholder: 'Selecciona una fecha',
                        soloLectura: true,
                        alTocar: _seleccionarFecha,
                        iconoFinal: Icons.calendar_today_outlined,
                        mensajeError: _errorFecha,
                      ),
                      const SizedBox(height: 16),
                      Input(
                        etiqueta: 'Hora',
                        controlador: _cHora,
                        placeholder: 'Selecciona una hora',
                        soloLectura: true,
                        alTocar: _seleccionarHora,
                        mensajeError: _errorHora,
                      ),
                      const SizedBox(height: 16),
                      Input(
                        etiqueta: 'Tipo de consulta',
                        controlador: _cTipo,
                        placeholder: 'Seguimiento',
                        mensajeError: _errorTipo,
                        alCambiar: (_) {
                          if (_errorTipo != null) {
                            setState(() => _errorTipo = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Input(
                        etiqueta: 'Observación',
                        controlador: _cObservacion,
                        placeholder: 'Opcional',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _guardando ? null : _guardar,
                          style: FilledButton.styleFrom(
                            backgroundColor: auxiliar,
                            foregroundColor: secundario,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _editando
                                      ? 'Guardar cambios'
                                      : 'Agendar cita',
                                  style: const TextStyle(
                                    fontFamily: bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class CitaCreateView extends StatelessWidget {
  const CitaCreateView({super.key});

  @override
  Widget build(BuildContext context) => const CitaFormularioView();
}

class CitaEditView extends StatelessWidget {
  const CitaEditView({super.key, required this.cita});
  final Cita cita;

  @override
  Widget build(BuildContext context) => CitaFormularioView(cita: cita);
}
