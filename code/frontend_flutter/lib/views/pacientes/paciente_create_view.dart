import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../services/paciente_service.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';

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

  Future<void> _guardarPaciente() async {
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
      await PacienteService().createPaciente(
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
      backgroundColor: blancoplomizo,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFB),
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
          Input(etiqueta: 'Nombre', controlador: _cNombre, placeholder: 'Text'),
          const SizedBox(height: 32),
          const Text(
            'Sexo',
            style: TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: regular,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 8),
          _campoSexo(),
          const SizedBox(height: 31),
          Input(etiqueta: 'Fecha (yyyy-MM-dd)', controlador: _cFecha),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Teléfono',
            controlador: _cTelefono,
            placeholder: 'Telefono',
            tipoTeclado: TextInputType.phone,
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 138,
              height: 46,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarPaciente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDDFFDF),
                  foregroundColor: const Color(0xFF616161),
                  disabledBackgroundColor: const Color(0xFFDDFFDF),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFDDFFDF)),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(fontFamily: semibold, fontSize: 15),
                      ),
              ),
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
          activeColor: const Color(0xFF616161),
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
        style: const TextStyle(
          color: Color(0xFF2E2E2E),
          fontFamily: regular,
          fontSize: 14,
          height: 16 / 14,
        ),
      ),
    );
  }
}
