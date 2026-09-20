import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/comidas_dia.dart';
import '../../models/dieta.dart';
import '../../models/paciente.dart';
import '../../services/dieta_service.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/top_app_bar.dart';
import '../home_view/home_view.dart';
import 'registrar_desayuno_view.dart';

/// Pantalla 23c del flujo de Figma. Los datos son locales por ahora.
class DetalleDesayunoView extends StatefulWidget {
  const DetalleDesayunoView({
    super.key,
    required this.paciente,
    required this.dieta,
    required this.comida,
    required this.nombreDia,
    required this.tipoComida,
    required this.nombreComida,
  });

  final Paciente paciente;
  final Dieta dieta;
  final Comida comida;
  final String nombreDia;
  final String tipoComida;
  final String nombreComida;

  @override
  State<DetalleDesayunoView> createState() => _DetalleDesayunoViewState();
}

class _DetalleDesayunoViewState extends State<DetalleDesayunoView> {
  late final List<Alimento> _alimentos;

  @override
  void initState() {
    super.initState();
    _alimentos = List.of(widget.comida.alimentos);
  }

  int get _total =>
      _alimentos.fold(0, (suma, alimento) => suma + alimento.calorias);

  String get _dia =>
      '${widget.nombreDia[0].toUpperCase()}${widget.nombreDia.substring(1)}';

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
              titulo: 'Detalle del ${widget.nombreComida.toLowerCase()}',
              alVolver: () => Navigator.pop(context),
            ),
            Expanded(child: _contenido(context)),
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

  Widget _contenido(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$_dia · ${widget.dieta.nombre}', style: _caption),
        const SizedBox(height: 14),
        Text(widget.nombreComida, style: _heading),
        const SizedBox(height: 14),
        _lista(context),
        const SizedBox(height: 14),
        _resumen(),
        const SizedBox(height: 14),
        SizedBox(
          height: 46,
          child: OutlinedButton(
            onPressed: _anadirAlimento,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xFF303B1C)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('+ Añadir alimento', style: _buttonText),
          ),
        ),
      ],
    ),
  );

  Widget _lista(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: superficie,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: bordeSuave),
    ),
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Alimentos registrados', style: _listTitle),
          ),
        ),
        ...List.generate(_alimentos.length, (indice) {
          final alimento = _alimentos[indice];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alimento.nombre, style: _foodName),
                          const SizedBox(height: 4),
                          Text(
                            '${alimento.porcion} · ${alimento.calorias} kcal',
                            style: _foodDetail,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _editarAlimento(alimento),
                      style: _actionStyle,
                      child: const Text('Editar', style: _editAction),
                    ),
                    TextButton(
                      onPressed: () => _eliminarAlimento(alimento),
                      style: _actionStyle,
                      child: const Text('Eliminar', style: _deleteAction),
                    ),
                  ],
                ),
              ),
              if (indice < _alimentos.length - 1)
                const Divider(height: 1, color: Color(0xFFD1D1C9)),
            ],
          );
        }),
      ],
    ),
  );

  Widget _resumen() => Container(
    height: 62,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
    decoration: BoxDecoration(
      color: superficie,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: bordeSuave),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total del ${widget.nombreComida.toLowerCase()}',
          style: _foodDetail,
        ),
        Text('$_total kcal', style: _totalText),
      ],
    ),
  );

  Future<void> _anadirAlimento() async {
    final resultado = await Navigator.push<Object>(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarDesayunoView(
          paciente: widget.paciente,
          dieta: widget.dieta,
          diaSemana: widget.comida.diaSemana,
          nombreDia: widget.nombreDia,
          tipoComida: widget.tipoComida,
          nombreComida: widget.nombreComida,
        ),
      ),
    );
    if (resultado is Comida && mounted) {
      setState(() {
        _alimentos
          ..clear()
          ..addAll(resultado.alimentos);
      });
    }
  }

  Future<void> _editarAlimento(Alimento alimento) async {
    final resultado = await Navigator.push<Object>(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarDesayunoView(
          paciente: widget.paciente,
          dieta: widget.dieta,
          diaSemana: widget.comida.diaSemana,
          nombreDia: widget.nombreDia,
          tipoComida: widget.tipoComida,
          nombreComida: widget.nombreComida,
          alimentoEditar: alimento,
        ),
      ),
    );
    if (resultado is Alimento && mounted) {
      final indice = _alimentos.indexWhere((item) => item.id == resultado.id);
      if (indice >= 0) {
        setState(() => _alimentos[indice] = resultado);
      }
    }
  }

  Future<void> _eliminarAlimento(Alimento alimento) async {
    try {
      await DietaService().eliminarAlimento(alimento.id);
      if (mounted) {
        setState(
          () => _alimentos.removeWhere((item) => item.id == alimento.id),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }
}

const _caption = TextStyle(
  color: secundario,
  fontFamily: regular,
  fontSize: 14,
  height: 20 / 14,
);
const _heading = TextStyle(
  color: secundario,
  fontFamily: bold,
  fontSize: 24,
  fontWeight: FontWeight.w700,
  height: 28 / 24,
);
const _listTitle = TextStyle(
  color: secundario,
  fontFamily: medium,
  fontSize: 18,
  fontWeight: FontWeight.w500,
);
const _foodName = TextStyle(
  color: secundario,
  fontFamily: medium,
  fontSize: 18,
  fontWeight: FontWeight.w500,
);
const _foodDetail = TextStyle(
  color: Color(0xFF616B5E),
  fontFamily: regular,
  fontSize: 14,
);
const _totalText = TextStyle(
  color: secundario,
  fontFamily: medium,
  fontSize: 18,
  fontWeight: FontWeight.w500,
);
const _buttonText = TextStyle(
  fontFamily: semibold,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
const _editAction = TextStyle(
  color: secundario,
  fontFamily: semibold,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
const _deleteAction = TextStyle(
  color: Color(0xFFD32F2F),
  fontFamily: semibold,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
final _actionStyle = TextButton.styleFrom(
  minimumSize: const Size(0, 36),
  padding: const EdgeInsets.symmetric(horizontal: 6),
);
