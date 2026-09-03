import 'package:flutter/material.dart';

import '../consts/styles.dart';

class BarraInferior extends StatelessWidget {
  const BarraInferior({
    super.key,
    required this.indiceSeleccionado,
    required this.alCambiar,
  });

  final int indiceSeleccionado;
  final ValueChanged<int> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 69,
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFB),
        border: Border(top: BorderSide(color: Color(0xFFC7C7C7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ElementoNavegacion(
            texto: 'Inicio',
            seleccionado: indiceSeleccionado == 0,
            alTocar: () => alCambiar(0),
          ),
          _ElementoNavegacion(
            texto: 'Pacientes',
            seleccionado: indiceSeleccionado == 1,
            alTocar: () => alCambiar(1),
          ),
          _ElementoNavegacion(
            texto: 'Evaluaciones',
            seleccionado: indiceSeleccionado == 2,
            alTocar: () => alCambiar(2),
          ),
        ],
      ),
    );
  }
}

class _ElementoNavegacion extends StatelessWidget {
  const _ElementoNavegacion({
    required this.texto,
    required this.seleccionado,
    required this.alTocar,
  });

  final String texto;
  final bool seleccionado;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alTocar,
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: seleccionado
                    ? const Color(0xFFADADAD)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              texto,
              style: TextStyle(
                color: seleccionado
                    ? const Color(0xFF2E2E2E)
                    : const Color(0xFF616161),
                fontFamily: seleccionado ? semibold : regular,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
