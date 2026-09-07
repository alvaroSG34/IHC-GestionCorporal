import 'package:flutter/material.dart';

import '../consts/styles.dart';

class TarjetaPaciente extends StatelessWidget {
  const TarjetaPaciente({
    super.key,
    required this.nombre,
    required this.alTocar,
  });

  final String nombre;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE0E0E0),
      child: InkWell(
        onTap: alTocar,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  color: Color(0xFFADADAD),
                  size: 40,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: figmaBody.copyWith(color: const Color(0xFF2E2E2E)),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF616161),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
