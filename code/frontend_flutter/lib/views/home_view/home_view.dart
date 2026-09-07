import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../widgets/barra_inferior.dart';
import '../../widgets/top_app_bar.dart';
import '../pacientes/paciente_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _indiceSeleccionado = 0;

  final List<Widget> _pantallas = const [
    _PantallaInicio(),
    PacienteView(),
    _PantallaVacia(nombre: 'Evaluaciones'),
    _PantallaVacia(nombre: 'Más'),
  ];

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

class _PantallaVacia extends StatelessWidget {
  const _PantallaVacia({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        nombre,
        style: TextStyle(color: plomo, fontFamily: regular, fontSize: 18),
      ),
    );
  }
}
