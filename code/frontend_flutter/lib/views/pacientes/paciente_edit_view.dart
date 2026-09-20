import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/paciente.dart';
import '../../services/paciente_service.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/dialogo_confirmacion.dart';
import '../../widgets/input.dart';

class PacienteEditView extends StatefulWidget {
  const PacienteEditView({super.key, required this.paciente});

  final Paciente paciente;

  @override
  State<PacienteEditView> createState() => _PacienteEditViewState();
}

class _PacienteEditViewState extends State<PacienteEditView> {
  late final TextEditingController _cNombre;
  late final TextEditingController _cTelefono;
  late final TextEditingController _cFecha;
  late String _sexo;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cNombre = TextEditingController(text: widget.paciente.nombre);
    _cTelefono = TextEditingController(text: widget.paciente.telefono ?? '');
    _cFecha = TextEditingController(
      text: widget.paciente.fechaNacimiento.toIso8601String().split('T').first,
    );
    _sexo = widget.paciente.sexo;
  }

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
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (_cNombre.text.trim().isEmpty || _cFecha.text.trim().isEmpty) {
      _mostrarMensaje('Completa nombre y fecha');
      return;
    }

    final fechaNacimiento = DateTime.tryParse(_cFecha.text.trim());
    if (fechaNacimiento == null) {
      _mostrarMensaje('La fecha debe tener el formato año-mes-día');
      return;
    }

    setState(() => _guardando = true);

    try {
      await PacienteService().updatePaciente(
        pacienteId: widget.paciente.id,
        nombre: _cNombre.text.trim(),
        sexo: _sexo,
        fechaNacimiento: fechaNacimiento,
        telefono: _cTelefono.text.trim().isEmpty
            ? null
            : _cTelefono.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mostrarMensaje('Error: $error');
    }
  }

  Future<void> _confirmarEliminacion() async {
    final confirmar = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Eliminar paciente',
      mensaje: '¿Deseas eliminar este paciente?',
    );

    if (!confirmar || !mounted) return;

    try {
      await PacienteService().deletePaciente(widget.paciente.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _mostrarMensaje('Error: $error');
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
                  Text('Editar paciente', style: _tituloEditar),
                  SizedBox(height: 2),
                  Text('Actualiza los datos de su perfil', style: _ayudaEditar),
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
                  iconoInicial: Icons.person_outline,
                ),
                const SizedBox(height: 8),
                const Text('Sexo', style: _etiquetaEditar),
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
                ),
                const SizedBox(height: 8),
                Input(
                  etiqueta: 'Telefono',
                  controlador: _cTelefono,
                  tipoTeclado: TextInputType.phone,
                  iconoInicial: Icons.person_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          BotonGuardar(
            texto: 'Guardar cambios',
            alPresionar: _guardando ? null : _guardarCambios,
            estaCargando: _guardando,
            anchoCompleto: true,
            colorFondo: const Color(0xFF303B1C),
            colorTexto: superficie,
            alto: 54,
            radio: 16,
            conSombra: true,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: TextButton(
              onPressed: _confirmarEliminacion,
              style: TextButton.styleFrom(
                alignment: Alignment.center,
                foregroundColor: const Color(0xFFDC1A1D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                'Eliminar paciente',
                style: figmaButton.copyWith(
                  color: const Color(0xFFDC1A1D),
                  fontFamily: regular,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
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
                Text(etiqueta, style: _textoOpcionEditar),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _tituloEditar = TextStyle(
  color: secundario,
  fontFamily: bold,
  fontSize: 27,
  fontWeight: FontWeight.w700,
  height: 32 / 27,
);

const _ayudaEditar = TextStyle(
  color: Color(0xFF666B63),
  fontFamily: regular,
  fontSize: 15,
  fontWeight: FontWeight.w400,
  height: 19 / 15,
);

const _etiquetaEditar = TextStyle(
  color: secundario,
  fontFamily: bold,
  fontSize: 17,
  fontWeight: FontWeight.w700,
  height: 22 / 17,
);

const _textoOpcionEditar = TextStyle(
  color: secundario,
  fontFamily: medium,
  fontSize: 15,
  fontWeight: FontWeight.w500,
  height: 20 / 15,
);
