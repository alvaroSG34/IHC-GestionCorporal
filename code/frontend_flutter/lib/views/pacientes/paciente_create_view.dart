import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../services/paciente_service.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/dialogo_exito.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';
import 'paciente_detalle_view.dart';

class PacienteCreateView extends StatefulWidget {
  const PacienteCreateView({super.key});

  @override
  State<PacienteCreateView> createState() => _PacienteCreateViewState();
}

class _PacienteCreateViewState extends State<PacienteCreateView> {
  final _cNombre = TextEditingController();
  final _cTelefono = TextEditingController();
  final _cFecha = TextEditingController();

  String _sexo = 'M';
  bool _guardando = false;
  String? _errorNombre;
  String? _errorFecha;
  String? _errorTelefono;

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final fechaActual = DateTime.tryParse(_cFecha.text) ?? hoy;
    final fechaInicial = fechaActual.isAfter(hoy) ? hoy : fechaActual;
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(1900),
      lastDate: hoy,
    );

    if (fecha != null) {
      setState(() {
        _cFecha.text = fecha.toIso8601String().split('T').first;
        _errorFecha = null;
      });
    }
  }

  Future<void> _guardarPaciente() async {
    final nombre = _cNombre.text.trim();
    final fechaTexto = _cFecha.text.trim();
    final telefono = _cTelefono.text.trim();
    final fechaNacimiento = DateTime.tryParse(fechaTexto);
    final nombreValido = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');
    final hoy = DateTime.now();
    final fechaMaxima = DateTime(hoy.year, hoy.month, hoy.day);

    final errorNombre = !nombreValido.hasMatch(nombre)
        ? 'Solo se permiten caracteres a-z.'
        : null;
    final errorFecha =
        (fechaNacimiento == null || fechaNacimiento.isAfter(fechaMaxima))
        ? 'Fecha inválida.'
        : null;
    final errorTelefono =
        telefono.isNotEmpty && !RegExp(r'^\d+$').hasMatch(telefono)
        ? 'Solo se permiten numeros.'
        : null;

    if (nombre.isEmpty ||
        fechaTexto.isEmpty ||
        errorNombre != null ||
        errorFecha != null ||
        errorTelefono != null) {
      setState(() {
        _errorNombre = errorNombre;
        _errorFecha = errorFecha;
        _errorTelefono = errorTelefono;
      });
      return;
    }

    setState(() => _guardando = true);

    try {
      final pacienteCreado = await PacienteService().createPaciente(
        nombre: nombre,
        sexo: _sexo,
        fechaNacimiento: fechaNacimiento!,
        telefono: telefono.isEmpty ? null : telefono,
      );

      if (!mounted) return;
      await DialogoExito.mostrar(
        context,
        titulo: 'Paciente creado',
        mensaje: 'Paciente creado correctamente.',
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement<bool, bool>(
        MaterialPageRoute(
          builder: (_) => PacienteDetalleView(paciente: pacienteCreado),
        ),
        result: true,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mostrarMensaje('Error: $error');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _cNombre.dispose();
    _cTelefono.dispose();
    _cFecha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: const Color(0xFFB8B8B8)),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              TopAppBar(
                titulo: 'Nuevo paciente',
                alVolver: () => Navigator.pop(context),
              ),
              Expanded(child: _formulario()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Nombre',
            controlador: _cNombre,
            placeholder: 'Ej. Marcelo',
            mensajeError: _errorNombre,
            alCambiar: (_) {
              if (_errorNombre != null) setState(() => _errorNombre = null);
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Sexo',
            style: figmaCaption.copyWith(
              color: const Color(0xFF2E2E2E),
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 8),
          _campoSexo(),
          const SizedBox(height: 31),
          Input(
            etiqueta: 'Fecha de nacimiento',
            controlador: _cFecha,
            placeholder: 'Selecciona una fecha',
            soloLectura: true,
            alTocar: _seleccionarFecha,
            iconoFinal: Icons.calendar_today_outlined,
            mensajeError: _errorFecha,
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Teléfono',
            controlador: _cTelefono,
            placeholder: 'Telefono',
            tipoTeclado: TextInputType.phone,
            mensajeError: _errorTelefono,
            alCambiar: (_) {
              if (_errorTelefono != null) {
                setState(() => _errorTelefono = null);
              }
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: BotonGuardar(
              texto: 'Guardar',
              alPresionar: _guardando ? null : _guardarPaciente,
              estaCargando: _guardando,
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoSexo() {
    return RadioGroup<String>(
      groupValue: _sexo,
      onChanged: (nuevoValor) {
        if (nuevoValor != null) setState(() => _sexo = nuevoValor);
      },
      child: SizedBox(
        height: 22,
        child: Row(
          children: [
            const SizedBox(width: 54),
            _opcionSexo(valor: 'M', etiqueta: 'Masculino'),
            const SizedBox(width: 16),
            _etiquetaSexo('Masculino'),
            const SizedBox(width: 16),
            _opcionSexo(valor: 'F', etiqueta: 'Femenino'),
            const SizedBox(width: 16),
            _etiquetaSexo('Femenino'),
          ],
        ),
      ),
    );
  }

  Widget _opcionSexo({required String valor, required String etiqueta}) {
    return Semantics(
      label: etiqueta,
      inMutuallyExclusiveGroup: true,
      checked: _sexo == valor,
      child: SizedBox(
        width: 22,
        height: 22,
        child: Radio<String>(
          value: valor,
          activeColor: textoSecundario,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
      ),
    );
  }

  Widget _etiquetaSexo(String texto) {
    return SizedBox(
      width: 88,
      child: Text(
        texto,
        style: figmaCaption.copyWith(
          color: const Color(0xFF2E2E2E),
          height: 16 / 14,
        ),
      ),
    );
  }
}
