import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/cita.dart';
import '../../services/cita_service.dart';
import '../../widgets/top_app_bar.dart';
import 'cita_detalle_view.dart';
import 'cita_formatters.dart';
import 'cita_formulario_view.dart';

class CitasView extends StatefulWidget {
  const CitasView({super.key});

  @override
  State<CitasView> createState() => _CitasViewState();
}

class _CitasViewState extends State<CitasView> {
  late Future<AgendaCitas> _futuroAgenda;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() => _futuroAgenda = CitaService().getAgenda();

  Future<void> _abrirFormulario() async {
    final cambio = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CitaCreateView()),
    );
    if (cambio == true && mounted) setState(_recargar);
  }

  Future<void> _abrirDetalle(Cita cita) async {
    final cambio = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CitaDetalleView(cita: cita)),
    );
    if (cambio == true && mounted) setState(_recargar);
  }

  @override
  Widget build(BuildContext context) => Material(
    color: background,
    child: Column(
      children: [
        TopAppBar(titulo: 'Citas', alAccion: _abrirFormulario),
        Expanded(
          child: FutureBuilder<AgendaCitas>(
            future: _futuroAgenda,
            builder: (context, estado) {
              if (estado.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (estado.hasError) {
                return _EstadoAgenda(
                  mensaje: 'no se pudo cargar la agenda.',
                  accion: () => setState(_recargar),
                );
              }
              final agenda = estado.data!;
              if (agenda.todas.isEmpty) {
                return const _EstadoAgenda(
                  mensaje: 'no tienes citas registradas.',
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(26, 18, 26, 24),
                children: [
                  _seccion('Hoy', agenda.hoy),
                  _seccion('Proximas', agenda.proximas),
                  _seccion('Anteriores', agenda.anteriores),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _seccion(String titulo, List<Cita> citas) {
    if (citas.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: secundario,
              fontFamily: bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 9),
          ...citas.asMap().entries.map(
            (entrada) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: TarjetaCita(
                cita: entrada.value,
                numero: entrada.key + 1,
                alTocar: () => _abrirDetalle(entrada.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TarjetaCita extends StatelessWidget {
  const TarjetaCita({
    super.key,
    required this.cita,
    required this.numero,
    required this.alTocar,
  });

  final Cita cita;
  final int numero;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) => Material(
    color: blanco,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 81,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDBDBDB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$numero',
                style: const TextStyle(fontFamily: bold, fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cita.paciente.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2E2E2E),
                      fontFamily: bold,
                      fontSize: 17,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fechaHoraCita(cita.fechaHora),
                    style: const TextStyle(
                      color: Color(0xFF616161),
                      fontSize: 12,
                      height: 1,
                    ),
                  ),
                  Text(
                    cita.tipoConsulta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF616161),
                      fontSize: 12,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '›',
              style: TextStyle(color: Color(0xFF616161), fontSize: 27),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EstadoAgenda extends StatelessWidget {
  const _EstadoAgenda({required this.mensaje, this.accion});
  final String mensaje;
  final VoidCallback? accion;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(mensaje, textAlign: TextAlign.center, style: figmaBody),
        if (accion != null)
          TextButton(onPressed: accion, child: const Text('Reintentar')),
      ],
    ),
  );
}
