import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../consts/styles.dart';

class DialogoExito extends StatelessWidget {
  const DialogoExito({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoAccion = 'Aceptar',
  });

  final String titulo;
  final String mensaje;
  final String textoAccion;

  static Future<void> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoAccion = 'Aceptar',
  }) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (contextoDialogo) => DialogoExito(
      titulo: titulo,
      mensaje: mensaje,
      textoAccion: textoAccion,
    ),
  );

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    elevation: 0,
    insetPadding: const EdgeInsets.symmetric(horizontal: 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: figmaHeading.copyWith(
              color: const Color(0xFF2E2E2E),
              fontFamily: semibold,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: figmaCaption.copyWith(
              color: const Color(0xFF2E2E2E),
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: secundario),
              child: Text(
                textoAccion,
                style: figmaButton.copyWith(color: secundario),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
