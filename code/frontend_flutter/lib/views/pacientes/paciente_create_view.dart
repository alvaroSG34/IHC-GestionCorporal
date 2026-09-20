import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../services/paciente_service.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/dialogo_exito.dart';
import '../../widgets/input.dart';
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
        ? 'Solo se permiten números.'
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
              _encabezado(),
              Expanded(child: _formulario()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado() {
    return SizedBox(
      height: 102,
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
                  width: 14,
                  height: 62,
                  child: Center(
                    child: Text(
                      '‹',
                      style: TextStyle(
                        color: secundario,
                        fontFamily: regular,
                        fontSize: 38,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nuevo paciente', style: _tituloPantalla),
                  SizedBox(height: 2),
                  Text(
                    'Completa los datos para crear su perfil',
                    style: _ayudaPantalla,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: superficie,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(46, 46, 31, 0.08),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Input(
                  etiqueta: 'Nombre',
                  controlador: _cNombre,
                  placeholder: 'Ej. Marcelo',
                  iconoInicial: Icons.person_outline,
                  mensajeError: _errorNombre,
                  alCambiar: (_) {
                    if (_errorNombre != null) {
                      setState(() => _errorNombre = null);
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Text('Sexo', style: _etiquetaFormulario),
                const SizedBox(height: 8),
                _campoSexo(),
                const SizedBox(height: 8),
                Input(
                  etiqueta: 'Fecha Nacimiento',
                  controlador: _cFecha,
                  placeholder: 'Selecciona una fecha',
                  soloLectura: true,
                  alTocar: _seleccionarFecha,
                  iconoInicial: Icons.person_outline,
                  iconoFinal: Icons.calendar_today_outlined,
                  mensajeError: _errorFecha,
                ),
                const SizedBox(height: 8),
                Input(
                  etiqueta: 'Telefono',
                  controlador: _cTelefono,
                  placeholder: 'Telefono',
                  tipoTeclado: TextInputType.phone,
                  iconoInicial: Icons.person_outline,
                  mensajeError: _errorTelefono,
                  alCambiar: (_) {
                    if (_errorTelefono != null) {
                      setState(() => _errorTelefono = null);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          BotonGuardar(
            texto: 'Guardar paciente',
            alPresionar: _guardando ? null : _guardarPaciente,
            estaCargando: _guardando,
            anchoCompleto: true,
            colorFondo: const Color(0xFF303B1C),
            colorTexto: superficie,
            alto: 54,
            radio: 16,
            conSombra: true,
          ),
        ],
      ),
    );
  }

  Widget _campoSexo() {
    return Row(
      children: [
        Expanded(
          child: _opcionSexo(valor: 'M', etiqueta: 'Masculino'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _opcionSexo(valor: 'F', etiqueta: 'Femenino'),
        ),
      ],
    );
  }

  Widget _opcionSexo({required String valor, required String etiqueta}) {
    final seleccionada = _sexo == valor;
    return Semantics(
      label: etiqueta,
      inMutuallyExclusiveGroup: true,
      checked: seleccionada,
      child: Material(
        color: seleccionada ? const Color(0xFF09E2FF) : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: () => setState(() => _sexo = valor),
          borderRadius: BorderRadius.circular(13),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: seleccionada
                  ? null
                  : Border.all(color: const Color(0xFFD6D1C7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  seleccionada
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: secundario,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(etiqueta, style: _textoOpcionSexo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _tituloPantalla = TextStyle(
  color: secundario,
  fontFamily: bold,
  fontSize: 27,
  fontWeight: FontWeight.w700,
  height: 32 / 27,
);

const _ayudaPantalla = TextStyle(
  color: Color(0xFF666B63),
  fontFamily: regular,
  fontSize: 15,
  fontWeight: FontWeight.w400,
  height: 19 / 15,
);

const _etiquetaFormulario = TextStyle(
  color: secundario,
  fontFamily: bold,
  fontSize: 17,
  fontWeight: FontWeight.w700,
  height: 22 / 17,
);

const _textoOpcionSexo = TextStyle(
  color: secundario,
  fontFamily: medium,
  fontSize: 15,
  fontWeight: FontWeight.w500,
  height: 20 / 15,
);
