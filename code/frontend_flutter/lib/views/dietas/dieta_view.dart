import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/dieta.dart';
import '../../models/paciente.dart';
import '../../services/dieta_service.dart';
import '../../services/plan_nutricional_pdf_service.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/top_app_bar.dart';
import '../home_view/home_view.dart';
import 'nueva_dieta_view.dart';
import 'plan_comidas_view.dart';

/// Pantallas 25 y 26 del flujo de Figma, conectadas a la dieta activa.
class DietaView extends StatefulWidget {
  const DietaView({super.key, required this.paciente});
  final Paciente paciente;

  @override
  State<DietaView> createState() => _DietaViewState();
}

class _DietaViewState extends State<DietaView> {
  late Future<Dieta?> _futuroDieta;
  bool _exportandoPdf = false;

  @override
  void initState() {
    super.initState();
    _futuroDieta = DietaService().getDietaActiva(widget.paciente.id);
  }

  void _recargarDieta() => setState(
    () => _futuroDieta = DietaService().getDietaActiva(widget.paciente.id),
  );

  int get _edad {
    final hoy = DateTime.now();
    final nacimiento = widget.paciente.fechaNacimiento;
    final yaCumplio =
        hoy.month > nacimiento.month ||
        (hoy.month == nacimiento.month && hoy.day >= nacimiento.day);
    return hoy.year - nacimiento.year - (yaCumplio ? 0 : 1);
  }

  String get _sexo => widget.paciente.sexo.toUpperCase() == 'M'
      ? 'Masculino'
      : widget.paciente.sexo.toUpperCase() == 'F'
      ? 'Femenino'
      : widget.paciente.sexo;

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
              titulo: 'Dieta de ${widget.paciente.nombre}',
              alVolver: () => Navigator.pop(context),
            ),
            Expanded(
              child: FutureBuilder<Dieta?>(
                future: _futuroDieta,
                builder: (context, estado) {
                  if (estado.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (estado.hasError) return _errorCarga();
                  return estado.data == null
                      ? _sinDieta()
                      : _dietaActiva(estado.data!);
                },
              ),
            ),
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

  Widget _errorCarga() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'No pudimos cargar la dieta.',
            style: TextStyle(
              color: secundario,
              fontFamily: medium,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _recargarDieta,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );

  Widget _sinDieta() => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(40, 187, 40, 32),
      child: Column(
        children: [
          const _IconoPlato(),
          const SizedBox(height: 52),
          Text(
            '${widget.paciente.nombre} aún no tiene una\ndieta configurada',
            textAlign: TextAlign.center,
            style: figmaHeading.copyWith(
              color: Colors.black,
              fontSize: 24,
              height: 29 / 24,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Crea un plan nutricional para comenzar a organizar\nsus comidas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontFamily: regular,
              fontSize: 14,
              height: 17 / 14,
            ),
          ),
          const SizedBox(height: 16),
          BotonGuardar(texto: 'Crear dieta', alPresionar: _crearDieta),
        ],
      ),
    ),
  );

  Future<void> _crearDieta() async {
    final creada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NuevaDietaView(paciente: widget.paciente),
      ),
    );
    if (creada == true && mounted) _recargarDieta();
  }

  Future<void> _exportarPdf(Dieta dieta) async {
    setState(() => _exportandoPdf = true);
    try {
      const dias = [
        'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo',
      ];
      final planSemanal = await Future.wait(
        dias.map(
          (dia) => DietaService().getComidasDelDia(
            dietaId: dieta.id,
            diaSemana: dia,
          ),
        ),
      );
      await PlanNutricionalPdfService.mostrarVistaPrevia(
        paciente: widget.paciente,
        dieta: dieta,
        planSemanal: planSemanal,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo generar el PDF: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _exportandoPdf = false);
    }
  }

  Widget _dietaActiva(Dieta dieta) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$_edad años · $_sexo',
          style: figmaCaption.copyWith(
            color: const Color(0xFF5B6654),
            fontSize: 14,
            height: 18 / 14,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          height: 214,
          padding: const EdgeInsets.fromLTRB(18, 19, 18, 18),
          decoration: BoxDecoration(
            color: superficie,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD2D2CB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dieta.nombre, style: _tituloPlan),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: auxiliar,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text('Activa', style: _estadoPlan),
              ),
              const SizedBox(height: 12),
              Text(dieta.objetivo, style: _detallePlan),
              const SizedBox(height: 10),
              Text(
                '${_calorias(dieta.caloriasDiarias)} kcal/día',
                style: _tituloPlan,
              ),
              const Spacer(),
              Text(
                'Desde el ${_fecha(dieta.fechaInicio)}',
                style: _detallePlan,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        BotonGuardar(
          texto: 'Plan de comidas',
          anchoCompleto: true,
          alPresionar: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PlanComidasView(paciente: widget.paciente, dieta: dieta),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: OutlinedButton(
            onPressed: _exportandoPdf ? null : () => _exportarPdf(dieta),
            style: OutlinedButton.styleFrom(
              foregroundColor: secundario,
              side: const BorderSide(color: secundario),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _exportandoPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Exportar PDF', style: _botonSecundario),
          ),
        ),
      ],
    ),
  );

  String _calorias(int calorias) => calorias.toString().replaceAllMapped(
    RegExp(r'(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );

  String _fecha(DateTime fecha) {
    const meses = [
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
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}

class _IconoPlato extends StatelessWidget {
  const _IconoPlato();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 142,
    height: 118,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 98,
          height: 98,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: blanco, width: 2),
          ),
        ),
        const Positioned(
          left: 0,
          child: Icon(Icons.restaurant, color: Colors.black, size: 48),
        ),
        const Positioned(
          right: 0,
          child: Icon(Icons.restaurant, color: Colors.black, size: 48),
        ),
      ],
    ),
  );
}

const _tituloPlan = TextStyle(
  color: secundario,
  fontFamily: bold,
  fontSize: 24,
  fontWeight: FontWeight.w700,
  height: 29 / 24,
);
const _estadoPlan = TextStyle(
  color: secundario,
  fontFamily: semibold,
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 18 / 14,
);
const _detallePlan = TextStyle(
  color: Color(0xFF5B6654),
  fontFamily: regular,
  fontSize: 14,
  height: 18 / 14,
);
const _botonSecundario = TextStyle(
  fontFamily: semibold,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
