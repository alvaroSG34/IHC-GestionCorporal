import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/cita.dart';
import '../../services/cita_service.dart';
import '../../widgets/dialogo_confirmacion.dart';
import '../../widgets/top_app_bar.dart';
import 'cita_formatters.dart';
import 'cita_formulario_view.dart';

class CitaDetalleView extends StatefulWidget {
  const CitaDetalleView({super.key, required this.cita});

  final Cita cita;

  @override
  State<CitaDetalleView> createState() => _CitaDetalleViewState();
}

class _CitaDetalleViewState extends State<CitaDetalleView> {
  late Cita _cita;
  bool _cancelando = false;
  bool _huboCambios = false;

  @override
  void initState() {
    super.initState();
    _cita = widget.cita;
  }

  Future<void> _editar(Cita cita) async {
    final cambio = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CitaEditView(cita: cita)),
    );
    if (cambio == true && mounted) {
      _huboCambios = true;
      Navigator.pop(context, true);
    }
  }

  Future<void> _cancelar(Cita cita) async {
    final confirmar = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Cancelar cita',
      mensaje: '¿Seguro que deseas cancelar esta cita?',
      textoConfirmar: 'Cancelar cita',
    );
    if (!confirmar || !mounted) return;
    setState(() => _cancelando = true);
    try {
      final cancelada = await CitaService().cancelarCita(cita.id);
      if (!mounted) return;
      setState(() {
        _cita = cancelada;
        _cancelando = false;
        _huboCambios = true;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _cancelando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  void _volver() => Navigator.pop(context, _huboCambios);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    body: SafeArea(
      child: Column(
        children: [
          TopAppBar(titulo: 'Cita', alVolver: _volver),
          Expanded(child: _contenido(_cita)),
        ],
      ),
    ),
  );

  Widget _contenido(Cita cita) {
    final cancelada = cita.estado == EstadoCita.cancelada;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: _tarjeta,
            child: Column(
              children: [
                _fila('Paciente', cita.paciente.nombre),
                _fila('Fecha', fechaCita(cita.fechaHora)),
                _fila('Hora', horaCita(cita.fechaHora)),
                _fila('Tipo', cita.tipoConsulta),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estado',
                        style: TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 13,
                        ),
                      ),
                      _estado(cita.estado),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _tarjeta,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Observación',
                  style: TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontFamily: bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cita.observacion?.isNotEmpty == true
                      ? cita.observacion!
                      : 'Sin observación.',
                  style: const TextStyle(
                    color: Color(0xFF616161),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!cancelada) ...[
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => _editar(cita),
                style: OutlinedButton.styleFrom(
                  backgroundColor: blanco,
                  foregroundColor: const Color(0xFF2E2E2E),
                  side: const BorderSide(color: Color(0xFFDBDBDB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Editar cita',
                  style: TextStyle(fontFamily: bold, fontSize: 17),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _cancelando ? null : () => _cancelar(cita),
              child: _cancelando
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Cancelar cita',
                      style: TextStyle(
                        color: Color(0xFFC73838),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fila(String etiqueta, String valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(color: Color(0xFF616161), fontSize: 13),
        ),
        Flexible(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF2E2E2E),
              fontFamily: regular,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _estado(EstadoCita estado) {
    final cancelada = estado == EstadoCita.cancelada;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: cancelada ? const Color(0xFFFADDDD) : const Color(0xFFE5F2CC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        estado.etiqueta,
        style: TextStyle(
          color: cancelada ? const Color(0xFFC73838) : secundario,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

final _tarjeta = BoxDecoration(
  color: blanco,
  border: Border.all(color: const Color(0xFFDBDBDB)),
  borderRadius: BorderRadius.circular(12),
);
