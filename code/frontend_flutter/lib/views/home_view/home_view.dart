import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/top_app_bar.dart';
import '../pacientes/paciente_view.dart';
import '../perfil/perfil_view.dart';

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
    PerfilView(),
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

class _PantallaInicio extends StatelessWidget {
  const _PantallaInicio();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        TopAppBar(titulo: 'Inicio'),
        Expanded(
          child: Center(
            child: Text(
              'Bienvenido!',
              textAlign: TextAlign.center,
              style: figmaHeading,
            ),
          ),
        ),
      ],
    );
  }
}
