import 'package:flutter/material.dart';

import '../consts/colors.dart';
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
      height: 58,
      color: background,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(height: 1, child: ColoredBox(color: primario)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  texto: 'Perfil',
                  seleccionado: indiceSeleccionado == 2,
                  alTocar: () => alCambiar(2),
                ),
              ],
            ),
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
        width: 80,
        height: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: seleccionado ? auxiliar : const Color(0xFFE0E0E0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              style: figmaCaption.copyWith(
                color: seleccionado
                    ? const Color(0xFF2E2E2E)
                    : const Color(0xFF616161),
                height: 16 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
