import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../consts/styles.dart';

class TarjetaPaciente extends StatelessWidget {
  const TarjetaPaciente({
    super.key,
    required this.nombre,
    required this.subtitulo,
    required this.alTocar,
  });

  final String nombre;
  final String subtitulo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: superficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: const Color.fromRGBO(46, 46, 31, 0.07),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
            child: Row(
              children: [
                _AvatarInicial(nombre: nombre),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF142112),
                          fontFamily: bold,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 24 / 19,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: figmaCaption.copyWith(
                          color: const Color(0xFF666B63),
                          height: 19 / 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF4F634A),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarInicial extends StatelessWidget {
  const _AvatarInicial({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.trim().isEmpty
        ? '?'
        : nombre.trim()[0].toUpperCase();

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFDCECCF),
        shape: BoxShape.circle,
      ),
      child: Text(
        inicial,
        style: const TextStyle(
          color: Color(0xFF21331F),
          fontFamily: bold,
          fontSize: 23,
          fontWeight: FontWeight.w700,
          height: 28 / 23,
        ),
      ),
    );
  }
}
