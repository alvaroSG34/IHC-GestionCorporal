import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/comidas_dia.dart';
import '../../models/dieta.dart';
import '../../models/paciente.dart';
import '../../services/dieta_service.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/top_app_bar.dart';
import '../home_view/home_view.dart';
import 'detalle_desayuno_view.dart';
import 'registrar_desayuno_view.dart';

/// Pantalla 23 del flujo de Figma, reutilizable para cada día del plan.
class ComidasDiaView extends StatefulWidget {
  const ComidasDiaView({
    super.key,
    required this.paciente,
    required this.dieta,
    required this.comidas,
    required this.diaAbreviado,
    required this.nombreDia,
  });

  final Paciente paciente;
  final Dieta dieta;
  final ComidasDia comidas;
  final String diaAbreviado;
  final String nombreDia;

  @override
  State<ComidasDiaView> createState() => _ComidasDiaViewState();
}

class _ComidasDiaViewState extends State<ComidasDiaView> {
  late ComidasDia _comidas;

  Paciente get paciente => widget.paciente;
  Dieta get dieta => widget.dieta;
  ComidasDia get comidas => _comidas;
  String get diaAbreviado => widget.diaAbreviado;
  String get nombreDia => widget.nombreDia;

  @override
  void initState() {
    super.initState();
    _comidas = widget.comidas;
  }

  Future<void> _recargarComidas() async {
    try {
      final actualizadas = await DietaService().getComidasDelDia(
        dietaId: dieta.id,
        diaSemana: comidas.diaSemana,
      );
      if (mounted) setState(() => _comidas = actualizadas);
    } catch (error) {
      if (!mounted) return;
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
              titulo: 'Comidas del $nombreDia',
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

  Widget _contenido(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$diaAbreviado · ${dieta.nombre}',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: regular,
            fontSize: 14,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 40),
        _tarjetaComida(
          context,
          nombre: 'Desayuno',
          icono: 'assets/icons/dietas/desayuno.svg',
          comida: comidas.desayuno,
          tipoComida: 'desayuno',
        ),
        const SizedBox(height: 24),
        _tarjetaComida(
          context,
          nombre: 'Almuerzo',
          icono: 'assets/icons/dietas/almuerzo.svg',
          comida: comidas.almuerzo,
          tipoComida: 'almuerzo',
        ),
        const SizedBox(height: 24),
        _tarjetaComida(
          context,
          nombre: 'Cena',
          icono: 'assets/icons/dietas/cena.svg',
          comida: comidas.cena,
          tipoComida: 'cena',
        ),
        const Spacer(),
        BotonGuardar(
          texto: 'Guardar $nombreDia',
          anchoCompleto: true,
          alPresionar: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Comidas del $nombreDia guardadas localmente.'),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _tarjetaComida(
    BuildContext context, {
    required String nombre,
    required String icono,
    required Comida? comida,
    required String tipoComida,
  }) => Material(
    color: superficie,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: () {
        if (comida != null && comida.alimentos.isNotEmpty) {
          _abrirDetalleComida(context, comida, tipoComida, nombre);
          return;
        }
        _abrirRegistroComida(context, tipoComida, nombre);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 129,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bordeSuave),
        ),
        child: Row(
          children: [
            SizedBox(width: 44, height: 44, child: SvgPicture.asset(icono)),
            const SizedBox(width: 56),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: bold,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 19),
                  Text(
                    _detalleComida(comida),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: regular,
                      fontSize: 18,
                      height: 20 / 18,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '+',
              style: TextStyle(
                color: Color(0xFF303B1C),
                fontFamily: regular,
                fontSize: 48,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String _detalleComida(Comida? comida) {
    if (comida == null || comida.alimentos.isEmpty) return 'Agregar\nalimentos';
    final cantidad = comida.alimentos.length;
    return '$cantidad ${cantidad == 1 ? 'alimento' : 'alimentos'}\n${_calorias(comida.totalCalorias)} kcal';
  }

  String _calorias(int calorias) => calorias.toString().replaceAllMapped(
    RegExp(r'(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );

  Future<void> _abrirRegistroComida(
    BuildContext context,
    String tipoComida,
    String nombreComida,
  ) async {
    final comida = await Navigator.push<Comida>(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarDesayunoView(
          paciente: paciente,
          dieta: dieta,
          diaSemana: comidas.diaSemana,
          nombreDia: nombreDia,
          tipoComida: tipoComida,
          nombreComida: nombreComida,
        ),
      ),
    );
    if (comida == null || !context.mounted) return;
    await _recargarComidas();
  }

  Future<void> _abrirDetalleComida(
    BuildContext context,
    Comida comida,
    String tipoComida,
    String nombreComida,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleDesayunoView(
          paciente: paciente,
          dieta: dieta,
          comida: comida,
          nombreDia: nombreDia,
          tipoComida: tipoComida,
          nombreComida: nombreComida,
        ),
      ),
    );
    if (context.mounted) await _recargarComidas();
  }
}
