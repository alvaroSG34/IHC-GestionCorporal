import 'package:flutter/material.dart';

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
      color: const Color(0xFFF0F0F0),
      child: InkWell(
        onTap: alTocar,
        child: SizedBox(
          height: 72,
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
                      color: Color(0xFF616161),
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
                    style: figmaBody.copyWith(color: const Color(0xFF616161)),
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
