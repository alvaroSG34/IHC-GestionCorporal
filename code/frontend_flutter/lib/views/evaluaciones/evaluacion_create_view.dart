import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/paciente.dart';
import '../../services/evaluacion_service.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/dialogo_exito.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';
import 'evaluacion_detalle_view.dart';

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
  String? _errorPeso;
  String? _errorAltura;
  String? _errorMasa;

  @override
  void initState() {
    super.initState();
    _controladorPeso.addListener(_calcularImc);
    _controladorAltura.addListener(_calcularImc);
  }

  void _calcularImc() {
    final peso = double.tryParse(
      _controladorPeso.text.trim().replaceAll(',', '.'),
    );
    final alturaCm = double.tryParse(
      _controladorAltura.text.trim().replaceAll(',', '.'),
    );

    if (peso == null || peso <= 0 || alturaCm == null || alturaCm <= 0) {
      _controladorImc.clear();
      return;
    }

    final alturaMetros = alturaCm / 100;
    final imc = peso / (alturaMetros * alturaMetros);
    _controladorImc.text = imc.toStringAsFixed(1);
  }

  Future<void> _guardarEvaluacion() async {
    final peso = double.tryParse(
      _controladorPeso.text.trim().replaceAll(',', '.'),
    );
    final altura = int.tryParse(_controladorAltura.text.trim());
    final masa = double.tryParse(
      _controladorMasa.text.trim().replaceAll(',', '.'),
    );

    final errorPeso = peso == null || peso <= 0
        ? 'El valor debe ser numerico.'
        : null;
    final errorAltura = altura == null || altura <= 0
        ? 'Altura debe ser mayor que 0'
        : null;
    final errorMasa = masa == null || masa <= 0 || masa > 100
        ? 'El valor debe estar entre 0 - 100.'
        : null;

    if (errorPeso != null || errorAltura != null || errorMasa != null) {
      setState(() {
        _errorPeso = errorPeso;
        _errorAltura = errorAltura;
        _errorMasa = errorMasa;
      });
      return;
    }

    setState(() => _guardando = true);

    try {
      final evaluacionCreada = await EvaluacionService().createEvaluacion(
        paciente: widget.paciente.id,
        altura: altura!,
        peso: peso!,
        masa: masa!,
        observacion: _controladorObservacion.text.trim().isEmpty
            ? null
            : _controladorObservacion.text.trim(),
      );

      if (!mounted) return;
      await DialogoExito.mostrar(
        context,
        titulo: 'Evaluación creada',
        mensaje: 'Evaluación creada correctamente.',
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement<bool, bool>(
        MaterialPageRoute(
          builder: (_) => EvaluacionDetalleView(
            evaluacion: evaluacionCreada,
            paciente: widget.paciente,
          ),
        ),
        result: true,
      );
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
    _controladorPeso.removeListener(_calcularImc);
    _controladorAltura.removeListener(_calcularImc);
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
            mensajeError: _errorPeso,
            alCambiar: (_) {
              if (_errorPeso != null) setState(() => _errorPeso = null);
            },
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Altura',
            controlador: _controladorAltura,
            tipoTeclado: TextInputType.number,
            unidad: 'cm',
            mensajeError: _errorAltura,
            alCambiar: (_) {
              if (_errorAltura != null) setState(() => _errorAltura = null);
            },
          ),
          const SizedBox(height: 8),
          Input(
            etiqueta: 'Masa muscular',
            controlador: _controladorMasa,
            tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
            unidad: '%',
            mensajeError: _errorMasa,
            alCambiar: (_) {
              if (_errorMasa != null) setState(() => _errorMasa = null);
            },
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
              color: textoSecundario,
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
                color: textoSecundario,
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
            child: BotonGuardar(
              texto: 'Guardar',
              alPresionar: _guardando ? null : _guardarEvaluacion,
              estaCargando: _guardando,
            ),
          ),
        ],
      ),
    );
  }
}
