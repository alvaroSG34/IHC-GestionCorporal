import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/dieta.dart';
import '../../models/paciente.dart';
import '../../services/dieta_service.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';
import '../home_view/home_view.dart';

/// Pantalla 21 del flujo de Figma.
///
/// El formulario funciona sólo de forma local mientras el backend de dietas no
/// esté disponible.
class NuevaDietaView extends StatefulWidget {
  const NuevaDietaView({super.key, required this.paciente, this.alCrear});

  final Paciente paciente;
  final ValueChanged<Dieta>? alCrear;

  @override
  State<NuevaDietaView> createState() => _NuevaDietaViewState();
}

class _NuevaDietaViewState extends State<NuevaDietaView> {
  final _nombre = TextEditingController(text: 'Plan equilibrio semanal');
  final _objetivo = TextEditingController(text: 'Mantenimiento saludable');
  final _calorias = TextEditingController(text: '1.850');
  final _fechaTexto = TextEditingController(text: '15 sep. 2026');
  DateTime _fecha = DateTime(2026, 9, 15);
  bool _guardando = false;
  String? _errorNombre;
  String? _errorObjetivo;
  String? _errorCalorias;

  int get _edad {
    final hoy = DateTime.now();
    final nacimiento = widget.paciente.fechaNacimiento;
    final yaCumplio =
        hoy.month > nacimiento.month ||
        (hoy.month == nacimiento.month && hoy.day >= nacimiento.day);
    return hoy.year - nacimiento.year - (yaCumplio ? 0 : 1);
  }

  String get _sexo {
    if (widget.paciente.sexo.toUpperCase() == 'M') return 'Masculino';
    if (widget.paciente.sexo.toUpperCase() == 'F') return 'Femenino';
    return widget.paciente.sexo;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _objetivo.dispose();
    _calorias.dispose();
    _fechaTexto.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fecha == null) return;
    setState(() {
      _fecha = fecha;
      _fechaTexto.text =
          '${fecha.day} ${_mesAbreviado(fecha.month)} ${fecha.year}';
    });
  }

  String _mesAbreviado(int mes) => const [
    'ene.',
    'feb.',
    'mar.',
    'abr.',
    'may.',
    'jun.',
    'jul.',
    'ago.',
    'sep.',
    'oct.',
    'nov.',
    'dic.',
  ][mes - 1];

  Future<void> _continuar() async {
    final nombre = _nombre.text.trim();
    final objetivo = _objetivo.text.trim();
    final calorias = int.tryParse(
      _calorias.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    setState(() {
      _errorNombre = nombre.isEmpty ? 'Ingresa un nombre para la dieta.' : null;
      _errorObjetivo = objetivo.isEmpty
          ? 'Ingresa el objetivo de la dieta.'
          : null;
      _errorCalorias = calorias == null || calorias <= 0
          ? 'Ingresa una cantidad válida de calorías.'
          : null;
    });
    if (_errorNombre != null ||
        _errorObjetivo != null ||
        _errorCalorias != null) {
      return;
    }
    setState(() => _guardando = true);
    try {
      final dieta = await DietaService().crearDieta(
        pacienteId: widget.paciente.id,
        nombre: nombre,
        objetivo: objetivo,
        caloriasDiarias: calorias!,
        fechaInicio: _fecha,
      );
      widget.alCrear?.call(dieta);
      if (mounted) Navigator.pop(context);
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
              titulo: 'Nueva dieta',
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
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.paciente.nombre,
          style: figmaBody.copyWith(color: textoSecundario, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          '$_edad años · $_sexo · IMC 24,7',
          style: figmaCaption.copyWith(color: textoSecundario),
        ),
        const SizedBox(height: 12),
        Text(
          'Datos de la dieta',
          style: figmaBody.copyWith(color: textoSecundario, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Input(
          etiqueta: 'Nombre de la dieta',
          controlador: _nombre,
          placeholder: 'Plan equilibrio semanal',
          mensajeError: _errorNombre,
          alCambiar: (_) {
            if (_errorNombre != null) setState(() => _errorNombre = null);
          },
        ),
        const SizedBox(height: 12),
        Input(
          etiqueta: 'Objetivo',
          controlador: _objetivo,
          placeholder: 'Mantenimiento saludable',
          mensajeError: _errorObjetivo,
          alCambiar: (_) {
            if (_errorObjetivo != null) setState(() => _errorObjetivo = null);
          },
        ),
        const SizedBox(height: 12),
        Input(
          etiqueta: 'Calorías diarias',
          controlador: _calorias,
          placeholder: '1.850',
          tipoTeclado: TextInputType.number,
          unidad: 'kcal',
          mensajeError: _errorCalorias,
          alCambiar: (_) {
            if (_errorCalorias != null) setState(() => _errorCalorias = null);
          },
        ),
        const SizedBox(height: 12),
        Input(
          etiqueta: 'Fecha de inicio',
          controlador: _fechaTexto,
          placeholder: '15 sep. 2026',
          soloLectura: true,
          alTocar: _seleccionarFecha,
          iconoFinal: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 12),
        Align(
          child: BotonGuardar(
            texto: 'Continuar',
            alPresionar: _guardando ? null : _continuar,
            estaCargando: _guardando,
          ),
        ),
      ],
    ),
  );
}
