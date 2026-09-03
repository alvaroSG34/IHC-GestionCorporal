import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/evaluacion.dart';
import '../../models/paciente.dart';
import '../../services/evaluacion_service.dart';
import '../../widgets/dialogo_confirmacion.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';

class EvaluacionEditView extends StatefulWidget {
  const EvaluacionEditView({
    super.key,
    required this.evaluacion,
    required this.paciente,
  });

  final Evaluacion evaluacion;
  final Paciente paciente;

  @override
  State<EvaluacionEditView> createState() => _EvaluacionEditViewState();
}

class _EvaluacionEditViewState extends State<EvaluacionEditView> {
  late final TextEditingController _controladorPeso;
  late final TextEditingController _controladorAltura;
  late final TextEditingController _controladorMasa;
  late final TextEditingController _controladorImc;
  late final TextEditingController _controladorObservacion;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _controladorPeso = TextEditingController(
      text: widget.evaluacion.peso.toString(),
    );
    _controladorAltura = TextEditingController(
      text: widget.evaluacion.altura.toString(),
    );
    _controladorMasa = TextEditingController(
      text: widget.evaluacion.masa_muscular.toString(),
    );
    _controladorImc = TextEditingController(
      text: widget.evaluacion.imc.toString(),
    );
    _controladorObservacion = TextEditingController(
      text: widget.evaluacion.observacion ?? '',
    );
  }

  Future<void> _guardarCambios() async {
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
      await EvaluacionService().updateEvaluacion(
        evaluacionId: widget.evaluacion.id,
        paciente: widget.paciente.id,
        altura: altura,
        peso: peso,
        masa: masa,
        observacion: _controladorObservacion.text.trim().isEmpty
            ? null
            : _controladorObservacion.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mostrarMensaje('Error: $error');
    }
  }

  Future<void> _eliminarEvaluacion() async {
    final confirmar = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Eliminar evaluación',
      mensaje: '¿Deseas eliminar esta evaluación?',
    );
    if (!confirmar || !mounted) return;

    try {
      await EvaluacionService().deleteEvaluacion(widget.evaluacion.id);
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
                titulo: 'Editar evaluación',
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
          Text(
            widget.paciente.nombre,
            style: const TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: regular,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Peso',
            controlador: _controladorPeso,
            tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
            unidad: 'kg',
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Altura',
            controlador: _controladorAltura,
            tipoTeclado: TextInputType.number,
            unidad: 'cm',
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Masa muscular',
            controlador: _controladorMasa,
            tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
            unidad: '%',
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'IMC',
            controlador: _controladorImc,
            soloLectura: true,
            unidad: 'kg/m²',
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
                onPressed: _guardando ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1FFD2),
                  foregroundColor: const Color(0xFF616161),
                  disabledBackgroundColor: const Color(0xFFD1FFD2),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFD1FFD2)),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(fontFamily: semibold, fontSize: 15),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 46,
            child: TextButton(
              onPressed: _eliminarEvaluacion,
              style: TextButton.styleFrom(
                alignment: Alignment.center,
                foregroundColor: const Color(0xFFDC1A1D),
              ),
              child: const Text(
                'Eliminar evaluación',
                style: TextStyle(fontFamily: regular, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
