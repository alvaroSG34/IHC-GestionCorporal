import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/top_app_bar.dart';
import '../pacientes/paciente_create_view.dart';
import '../pacientes/paciente_view.dart';
import '../citas/cita_detalle_view.dart';
import '../citas/cita_formulario_view.dart';
import '../citas/citas_view.dart';
import '../../models/cita.dart';
import '../../services/cita_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, this.indiceInicial = 0});

  final int indiceInicial;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late int _indiceSeleccionado;

  final List<Widget> _pantallas = const [
    _PantallaInicio(),
    PacienteView(),
    CitasView(),
  ];

  @override
  void initState() {
    super.initState();
    _indiceSeleccionado = widget.indiceInicial
        .clamp(0, _pantallas.length - 1)
        .toInt();
  }

  void _cambiarPantalla(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _indiceSeleccionado,
                children: _pantallas
                    .map((pantalla) => SizedBox.expand(child: pantalla))
                    .toList(),
              ),
            ),
            BarraInferior(
              indiceSeleccionado: _indiceSeleccionado,
              alCambiar: _cambiarPantalla,
            ),
          ],
        ),
      ),
    );
  }
}

class _PantallaInicio extends StatefulWidget {
  const _PantallaInicio();

  @override
  State<_PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<_PantallaInicio> {
  late Future<AgendaCitas> _futuroAgenda;

  @override
  void initState() {
    super.initState();
    _futuroAgenda = CitaService().getAgenda();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopAppBar(titulo: 'Inicio'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Bienvenido!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secundario,
                    fontFamily: bold,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 32 / 28,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fechaActual(),
                  textAlign: TextAlign.center,
                  style: figmaCaption.copyWith(color: const Color(0xFF616161)),
                ),
                const SizedBox(height: 24),
                const Text('Accesos r\u00e1pidos', style: _tituloSeccion),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _AccionRapida(
                        texto: '+  Nuevo paciente',
                        destacada: true,
                        alPresionar: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PacienteCreateView(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _AccionRapida(
                        texto: '+  Nueva cita',
                        alPresionar: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CitaCreateView(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pr\u00f3ximas consultas',
                      style: _tituloSeccion,
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HomeView(indiceInicial: 2),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF616161),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Ver todas',
                        style: TextStyle(fontFamily: regular, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FutureBuilder<AgendaCitas>(
                  future: _futuroAgenda,
                  builder: (context, estado) {
                    if (estado.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (estado.hasError || estado.data!.proximas.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'No hay próximas consultas.',
                          style: TextStyle(
                            color: Color(0xFF616161),
                            fontFamily: regular,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: estado.data!.proximas
                          .take(3)
                          .map(
                            (cita) => Padding(
                              padding: const EdgeInsets.only(top: 9),
                              child: _TarjetaConsulta(cita: cita),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _fechaActual() {
    const dias = [
      'Lunes',
      'Martes',
      'Mi\u00e9rcoles',
      'Jueves',
      'Viernes',
      'S\u00e1bado',
      'Domingo',
    ];
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final hoy = DateTime.now();
    return '${dias[hoy.weekday - 1]}, ${hoy.day} de ${meses[hoy.month - 1]}';
  }
}

const _tituloSeccion = TextStyle(
  color: secundario,
  fontFamily: bold,
  fontSize: 18,
  fontWeight: FontWeight.w700,
  height: 23 / 18,
);

class _AccionRapida extends StatelessWidget {
  const _AccionRapida({
    required this.texto,
    required this.alPresionar,
    this.destacada = false,
  });

  final String texto;
  final VoidCallback alPresionar;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: destacada ? auxiliar : blanco,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: destacada
                ? null
                : Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: secundario,
              fontFamily: bold,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaConsulta extends StatelessWidget {
  const _TarjetaConsulta({required this.cita});

  final Cita cita;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: blanco,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CitaDetalleView(cita: cita)),
        ),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 53,
                height: 31,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${cita.fechaHora.hour.toString().padLeft(2, '0')}:${cita.fechaHora.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: secundario,
                    fontFamily: medium,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cita.paciente.nombre,
                      style: const TextStyle(
                        color: secundario,
                        fontFamily: medium,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cita.tipoConsulta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: figmaCaption.copyWith(
                        color: const Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '›',
                style: TextStyle(
                  color: Color(0xFF616161),
                  fontFamily: regular,
                  fontSize: 24,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
