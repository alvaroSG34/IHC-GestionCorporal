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
import 'comidas_dia_view.dart';

/// Pantalla 22 del flujo de Figma, conectada a las comidas del día.
class PlanComidasView extends StatefulWidget {
  const PlanComidasView({
    super.key,
    required this.paciente,
    required this.dieta,
  });

  final Paciente paciente;
  final Dieta dieta;

  @override
  State<PlanComidasView> createState() => _PlanComidasViewState();
}

class _PlanComidasViewState extends State<PlanComidasView> {
  static const _dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const _diasApi = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];
  static const _diasCompletos = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];
  int _diaSeleccionado = 0;
  bool _cargandoDia = false;
  bool _descargandoPdf = false;

  Future<void> _descargarPdf() async {
    setState(() => _descargandoPdf = true);
    try {
      final planSemanal = await Future.wait(
        _diasApi.map(
          (dia) => DietaService().getComidasDelDia(
            dietaId: widget.dieta.id,
            diaSemana: dia,
          ),
        ),
      );
      await PlanNutricionalPdfService.mostrarVistaPrevia(
        paciente: widget.paciente,
        dieta: widget.dieta,
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
      if (mounted) setState(() => _descargandoPdf = false);
    }
  }

  Future<void> _abrirComidas() async {
    setState(() => _cargandoDia = true);
    try {
      final comidas = await DietaService().getComidasDelDia(
        dietaId: widget.dieta.id,
        diaSemana: _diasApi[_diaSeleccionado],
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ComidasDiaView(
            paciente: widget.paciente,
            dieta: widget.dieta,
            comidas: comidas,
            diaAbreviado: _dias[_diaSeleccionado],
            nombreDia: _diasCompletos[_diaSeleccionado],
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _cargandoDia = false);
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
              titulo: 'Plan de comidas',
              alVolver: () => Navigator.pop(context),
            ),
            Expanded(child: _contenido()),
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

  Widget _contenido() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${widget.dieta.nombre} · ${_formatearCalorias(widget.dieta.caloriasDiarias)} kcal',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: regular,
            fontSize: 14,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 49),
        const Text(
          '¿Qué día quieres organizar?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontFamily: bold,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 20 / 24,
          ),
        ),
        const SizedBox(height: 49),
        _selectorDias(),
        const SizedBox(height: 49),
        const Text(
          'Selecciona un día para registrar sus comidas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontFamily: regular,
            fontSize: 14,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 49),
        BotonGuardar(
          texto: 'Registrar comidas',
          anchoCompleto: true,
          estaCargando: _cargandoDia,
          alPresionar: _cargandoDia ? null : _abrirComidas,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _descargandoPdf ? null : _descargarPdf,
          icon: _descargandoPdf
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          label: Text(_descargandoPdf ? 'Generando PDF...' : 'Descargar PDF'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            foregroundColor: primario,
            side: const BorderSide(color: primario),
            textStyle: const TextStyle(
              fontFamily: semibold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _selectorDias() => SizedBox(
    height: 50,
    child: LayoutBuilder(
      builder: (context, restricciones) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: restricciones.maxWidth),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_dias.length, (indice) {
              final seleccionado = indice == _diaSeleccionado;
              return Padding(
                padding: EdgeInsets.only(
                  right: indice == _dias.length - 1 ? 0 : 8,
                ),
                child: Semantics(
                  button: true,
                  selected: seleccionado,
                  label: _dias[indice],
                  child: Material(
                    color: seleccionado ? auxiliar : blanco,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => setState(() => _diaSeleccionado = indice),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: seleccionado
                              ? null
                              : Border.all(color: const Color(0xFFC7C7C2)),
                        ),
                        child: Text(_dias[indice], style: _textoDia),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ),
  );

  String _formatearCalorias(int calorias) => calorias
      .toString()
      .replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => '.');
}

const _textoDia = TextStyle(
  color: Colors.black,
  fontFamily: semibold,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
