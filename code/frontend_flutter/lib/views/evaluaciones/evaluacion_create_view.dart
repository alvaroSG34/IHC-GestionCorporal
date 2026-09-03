import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/paciente.dart';
import '../../services/evaluacion_service.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';

class EvaluacionCreateView extends StatefulWidget {
  const EvaluacionCreateView({super.key, required this.paciente});

  final Paciente paciente;

  @override
  State<EvaluacionCreateView> createState() => _EvaluacionCreateViewState();
}

class _EvaluacionCreateViewState extends State<EvaluacionCreateView> {
  final _controladorPeso = TextEditingController();
  final _controladorAltura = TextEditingController();
  final _controladorMasa = TextEditingController();
  final _controladorImc = TextEditingController();
  final _controladorObservacion = TextEditingController();

  bool _guardando = false;

  Future<void> _guardarEvaluacion() async {
    final peso = double.tryParse(
      _controladorPeso.text.trim().replaceAll(',', '.'),
    );
    final altura = int.tryParse(_controladorAltura.text.trim());
    final masa = double.tryParse(
      _controladorMasa.text.trim().replaceAll(',', '.'),
    );

    if (peso == null || peso <= 0) {
      _mostrarMensaje('El peso debe ser mayor que cero');
      return;
    }
    if (altura == null || altura <= 0) {
      _mostrarMensaje('La altura debe ser mayor que cero');
      return;
    }
    if (masa == null || masa <= 0 || masa > 100) {
      _mostrarMensaje('La masa muscular debe estar entre 0 y 100');
      return;
    }

    setState(() => _guardando = true);

    try {
      await EvaluacionService().createEvaluacion(
        paciente: widget.paciente.id,
        altura: altura,
        peso: peso,
        masa: masa,
        observacion: _controladorObservacion.text.trim().isEmpty
            ? null
            : _controladorObservacion.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mostrarMensaje('Error al guardar la evaluación: $error');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _controladorPeso.dispose();
    _controladorAltura.dispose();
    _controladorMasa.dispose();
    _controladorImc.dispose();
    _controladorObservacion.dispose();
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
                titulo: 'Nueva evaluación',
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
          const SizedBox(height: 7),
          Semantics(
            label: 'Paciente: ${widget.paciente.nombre}',
            child: const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 153,
                height: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Input(
            etiqueta: 'Peso',
            controlador: _controladorPeso,
            tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Altura',
            controlador: _controladorAltura,
            tipoTeclado: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Masa muscular',
            controlador: _controladorMasa,
            tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'IMC',
            controlador: _controladorImc,
            soloLectura: true,
          ),
          const SizedBox(height: 32),
          const Text(
            'Observación',
            style: TextStyle(
              color: Color(0xFF616161),
              fontFamily: regular,
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 96,
            child: TextField(
              controller: _controladorObservacion,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                color: Color(0xFF616161),
                fontFamily: regular,
                fontSize: 16,
                height: 24 / 16,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                contentPadding: const EdgeInsets.all(8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFB8B8B8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFB8B8B8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 138,
              height: 46,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarEvaluacion,
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
}
