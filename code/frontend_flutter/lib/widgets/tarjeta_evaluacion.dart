import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../consts/styles.dart';

class TarjetaEvaluacion extends StatelessWidget {
  const TarjetaEvaluacion({
    super.key,
    required this.numero,
    required this.texto,
    required this.alTocar,
  });

  final String numero;
  final String texto;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBDBDB),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    numero,
                    style: const TextStyle(
                      color: textoSecundario,
                      fontFamily: regular,
                      fontSize: 16,
                      height: 24 / 16,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    texto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: figmaBody.copyWith(
                      color: textoSecundario,
                      fontSize: 18,
                      height: 22 / 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
