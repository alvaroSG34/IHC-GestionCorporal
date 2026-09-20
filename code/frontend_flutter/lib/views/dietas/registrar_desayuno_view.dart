import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/comidas_dia.dart';
import '../../models/dieta.dart';
import '../../models/paciente.dart';
import '../../services/dieta_service.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';
import '../home_view/home_view.dart';

/// Pantalla 24 del flujo de Figma.
/// El alimento se captura localmente hasta disponer del backend de dietas.
class RegistrarDesayunoView extends StatefulWidget {
  const RegistrarDesayunoView({
    super.key,
    required this.paciente,
    required this.dieta,
    required this.diaSemana,
    required this.nombreDia,
    required this.tipoComida,
    required this.nombreComida,
    this.alimentoEditar,
  });

  final Paciente paciente;
  final Dieta dieta;
  final String diaSemana;
  final String nombreDia;
  final String tipoComida;
  final String nombreComida;
  final Alimento? alimentoEditar;

  @override
  State<RegistrarDesayunoView> createState() => _RegistrarDesayunoViewState();
}

class _RegistrarDesayunoViewState extends State<RegistrarDesayunoView> {
  final _nombre = TextEditingController();
  final _porcion = TextEditingController();
  final _calorias = TextEditingController();
  String? _errorNombre;
  String? _errorPorcion;
  String? _errorCalorias;
  bool _guardando = false;

  bool get _editando => widget.alimentoEditar != null;

  @override
  void initState() {
    super.initState();
    final alimento = widget.alimentoEditar;
    if (alimento == null) return;
    _nombre.text = alimento.nombre;
    _porcion.text = alimento.porcion;
    _calorias.text = alimento.calorias.toString();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _porcion.dispose();
    _calorias.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final porcion = _porcion.text.trim();
    final calorias = int.tryParse(
      _calorias.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    setState(() {
      _errorNombre = nombre.isEmpty ? 'Ingresa el alimento.' : null;
      _errorPorcion = porcion.isEmpty ? 'Ingresa la porción.' : null;
      _errorCalorias = calorias == null || calorias < 0
          ? 'Ingresa las calorías.'
          : null;
    });
    if (nombre.isEmpty || porcion.isEmpty || calorias == null || calorias < 0) {
      return;
    }
    setState(() => _guardando = true);
    try {
      if (_editando) {
        final alimento = await DietaService().actualizarAlimento(
          alimentoId: widget.alimentoEditar!.id,
          nombre: nombre,
          porcion: porcion,
          calorias: calorias,
        );
        if (mounted) Navigator.pop<Alimento>(context, alimento);
      } else {
        final comida = await DietaService().agregarAlimento(
          dietaId: widget.dieta.id,
          diaSemana: widget.diaSemana,
          tipo: widget.tipoComida,
          nombre: nombre,
          porcion: porcion,
          calorias: calorias,
        );
        if (mounted) Navigator.pop<Comida>(context, comida);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: const Color(0xFFC7C7C7)),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            TopAppBar(
              titulo: _editando
                  ? 'Editar alimento'
                  : 'Registrar ${widget.nombreComida.toLowerCase()}',
              alVolver: () => Navigator.pop(context),
            ),
            Expanded(child: _formulario()),
            BarraInferior(
              indiceSeleccionado: 1,
              alCambiar: (indice) {
                if (indice == 1) return Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => HomeView(indiceInicial: indice),
                  ),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

  Widget _formulario() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${_nombreDiaCapitalizado()} · ${widget.dieta.nombre}',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: regular,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          _editando ? 'Editar alimento' : 'Agregar alimento',
          style: TextStyle(
            color: Colors.black,
            fontFamily: bold,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 22),
        Input(
          etiqueta: 'Nombre del alimento',
          controlador: _nombre,
          placeholder: 'Ej. Avena',
          mensajeError: _errorNombre,
          alCambiar: (_) {
            if (_errorNombre != null) setState(() => _errorNombre = null);
          },
        ),
        const SizedBox(height: 22),
        Input(
          etiqueta: 'Porción',
          controlador: _porcion,
          placeholder: 'Ej. 1 taza',
          mensajeError: _errorPorcion,
          alCambiar: (_) {
            if (_errorPorcion != null) setState(() => _errorPorcion = null);
          },
        ),
        const SizedBox(height: 22),
        Input(
          etiqueta: 'Calorias',
          controlador: _calorias,
          placeholder: 'Ej. 1000',
          tipoTeclado: TextInputType.number,
          unidad: 'kcal',
          mensajeError: _errorCalorias,
          alCambiar: (_) {
            if (_errorCalorias != null) setState(() => _errorCalorias = null);
          },
        ),
        const SizedBox(height: 22),
        BotonGuardar(
          texto: _editando ? 'Guardar cambios' : 'Guardar Alimento',
          anchoCompleto: true,
          alPresionar: _guardando ? null : _guardar,
          estaCargando: _guardando,
        ),
      ],
    ),
  );

  String _nombreDiaCapitalizado() =>
      '${widget.nombreDia[0].toUpperCase()}${widget.nombreDia.substring(1)}';
}
