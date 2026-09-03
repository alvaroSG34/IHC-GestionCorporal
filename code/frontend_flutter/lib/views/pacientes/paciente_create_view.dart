import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../services/paciente_service.dart';
import '../../widgets/barra_inferior.dart';

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
      _mostrarMensaje('completa nombre y fecha');
      return;
    }

    final fechaNacimiento = DateTime.tryParse(_cFecha.text.trim());
    if (fechaNacimiento == null) {
      _mostrarMensaje('la fecha debe tener el formato año-mes-dia');
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
            border: Border.all(color: const Color(0xFFC7C7C7)),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(child: _formulario()),
              BarraInferior(
                indiceSeleccionado: 1,
                alCambiar: (indice) {
                  if (indice == 1) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(23, 20, 23, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 30,
                ),
                icon: const Icon(Icons.chevron_left, size: 30),
                color: const Color(0xFF616161),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 11),
              Text(
                'Nuevo paciente',
                style: TextStyle(
                  color: const Color(0xFF2E2E2E),
                  fontFamily: semibold,
                  fontSize: 23,
                ),
              ),
            ],
          ),
          const SizedBox(height: 52),
          _etiqueta('Nombre'),
          const SizedBox(height: 10),
          _campoTexto(controller: _cNombre),
          const SizedBox(height: 18),
          _etiqueta('Sexo'),
          const SizedBox(height: 10),
          _campoSexo(),
          const SizedBox(height: 18),
          _etiqueta('Fecha de nacimiento'),
          const SizedBox(height: 10),
          _campoTexto(
            controller: _cFecha,
            hint: 'AAAA-MM-DD',
            colorHint: const Color(0xFFADADAD),
          ),
          const SizedBox(height: 18),
          _etiqueta('Teléfono'),
          const SizedBox(height: 10),
          _campoTexto(
            controller: _cTelefono,
            hint: 'Número de teléfono',
            colorHint: const Color(0xFFADADAD),
            tipoTeclado: TextInputType.phone,
          ),
          const SizedBox(height: 48),
          Center(
            child: SizedBox(
              width: 158,
              height: 48,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarPaciente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F0F0),
                  foregroundColor: const Color(0xFF2E2E2E),
                  disabledBackgroundColor: const Color(0xFFF0F0F0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFB8B8B8)),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Guardar',
                        style: TextStyle(fontFamily: semibold, fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(String texto) {
    return Text(
      texto,
      style: const TextStyle(color: Color(0xFF616161), fontSize: 14),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    String? hint,
    Color? colorHint,
    TextInputType? tipoTeclado,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipoTeclado,
      style: const TextStyle(color: Color(0xFF616161), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorHint ?? const Color(0xFF616161)),
        contentPadding: const EdgeInsets.only(bottom: 8),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }

  Widget _campoSexo() {
    return RadioGroup<String>(
      groupValue: _sexo,
      onChanged: (valor) {
        if (valor != null) setState(() => _sexo = valor);
      },
      child: Row(
        children: [
          const SizedBox(width: 48),
          const Radio<String>(value: 'M', activeColor: Color(0xFF616161)),
          const Text(
            'Masculino',
            style: TextStyle(color: Color(0xFF2E2E2E), fontSize: 14),
          ),
          const SizedBox(width: 28),
          const Radio<String>(value: 'F', activeColor: Color(0xFF616161)),
          const Text(
            'Femenino',
            style: TextStyle(color: Color(0xFF2E2E2E), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
