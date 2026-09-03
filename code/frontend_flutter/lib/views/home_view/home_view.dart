import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../widgets/barra_inferior.dart';
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
      backgroundColor: blancoplomizo,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFB),
            border: Border.all(color: const Color(0xFFC7C7C7)),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
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
      ),
    );
  }
}

class _PantallaInicio extends StatelessWidget {
  const _PantallaInicio();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Bienvenido!', style: TextStyle(fontSize: 24)),
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
