import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/paciente.dart';
import '../../services/evaluacion_service.dart';
import '../../widgets/barra_inferior.dart';

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

  @override
  void initState() {
    super.initState();
    _controladorPeso.addListener(_calcularImc);
    _controladorAltura.addListener(_calcularImc);
  }

  void _calcularImc() {
    final peso = double.tryParse(_controladorPeso.text.replaceAll(',', '.'));
    final altura = double.tryParse(
      _controladorAltura.text.replaceAll(',', '.'),
    );

    if (peso == null || altura == null || peso <= 0 || altura <= 0) {
      _controladorImc.text = '';
      return;
    }

    final alturaEnMetros = altura / 100;
    _controladorImc.text = (peso / (alturaEnMetros * alturaEnMetros))
        .toStringAsFixed(2);
  }

  Future<void> _guardarEvaluacion() async {
    final peso = double.tryParse(
      _controladorPeso.text.trim().replaceAll(',', '.'),
    );
    final altura = int.tryParse(_controladorAltura.text.trim());
    final masa = double.tryParse(
      _controladorMasa.text.trim().replaceAll(',', '.'),
    );

    if (peso == null || peso <= 0) {
      _mostrarMensaje('el peso debe ser mayor que cero');
      return;
    }
    if (altura == null || altura <= 0) {
      _mostrarMensaje('la altura debe ser mayor que cero');
      return;
    }
    if (masa == null || masa <= 0 || masa > 100) {
      _mostrarMensaje('la masa muscular debe estar entre 0 y 100');
      return;
    }

    setState(() => _guardando = true);

    try {
      await EvaluacionService().createEvaluacion(
        paciente: widget.paciente.id,
        altura: altura,
        peso: peso,
        masa: masa,
        observacion: _controladorObservacion.text.trim().isEmpty ? null : _controladorObservacion.text.trim(),
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
              Expanded(child: _formulario()),
              BarraInferior(
                indiceSeleccionado: 2,
                alCambiar: (indice) {
                  if (indice == 2) {
                    Navigator.pop(context);
                  }
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
      padding: const EdgeInsets.fromLTRB(18, 18, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 16,
                  height: 32,
                ),
                icon: const Icon(Icons.chevron_left, size: 32),
                color: const Color(0xFF616161),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 17),
              Text(
                'Nueva evaluación',
                style: TextStyle(
                  color: const Color(0xFF2E2E2E),
                  fontFamily: semibold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(widget.paciente.nombre, style: _estiloTexto()),
          const SizedBox(height: 18),
          _campoLinea('Peso', _controladorPeso, 'kg'),
          const SizedBox(height: 18),
          _campoLinea('Altura', _controladorAltura, 'cm', esEntero: true),
          const SizedBox(height: 18),
          _campoLinea('Masa muscular', _controladorMasa, '%'),
          const SizedBox(height: 18),
          _campoLinea('IMC', _controladorImc, 'kg/m²', editable: false),
          const SizedBox(height: 18),
          const Text(
            'Observación',
            style: TextStyle(color: Color(0xFF616161), fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controladorObservacion,
            maxLines: 4,
            style: _estiloTexto(),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF0F0F0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFB8B8B8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFB8B8B8)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: 138,
              height: 46,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarEvaluacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F0F0),
                  foregroundColor: const Color(0xFF616161),
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
                        style: TextStyle(fontFamily: semibold, fontSize: 15),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoLinea(
    String etiqueta,
    TextEditingController controlador,
    String unidad, {
    bool editable = true,
    bool esEntero = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(color: Color(0xFF616161), fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controlador,
                readOnly: !editable,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: !esEntero,
                ),
                style: _estiloTexto(),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 6),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9E9E9E)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                unidad,
                style: const TextStyle(color: Color(0xFF616161), fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  TextStyle _estiloTexto() {
    return const TextStyle(color: Color(0xFF616161), fontSize: 14);
  }
}
