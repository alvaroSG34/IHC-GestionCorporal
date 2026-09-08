import 'package:flutter/material.dart';

import '../consts/styles.dart';

class DialogoConfirmacion extends StatelessWidget {
  const DialogoConfirmacion({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoCancelar = 'Cancelar',
    this.textoConfirmar = 'Eliminar',
  });

  final String titulo;
  final String mensaje;
  final String textoCancelar;
  final String textoConfirmar;

  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoCancelar = 'Cancelar',
    String textoConfirmar = 'Eliminar',
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierColor: const Color(0x52000000),
          builder: (_) => DialogoConfirmacion(
            titulo: titulo,
            mensaje: mensaje,
            textoCancelar: textoCancelar,
            textoConfirmar: textoConfirmar,
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: Color(0xFF2E2E2E),
                fontFamily: semibold,
                fontSize: 20,
                height: 28 / 20,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: const TextStyle(
                color: Color(0xFF2E2E2E),
                fontFamily: regular,
                fontSize: 16,
                height: 24 / 16,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _AccionDialogo(
                    texto: textoCancelar,
                    alTocar: () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: 8),
                  _AccionDialogo(
                    texto: textoConfirmar,
                    color: const Color(0xFFDC1A1D),
                    alTocar: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccionDialogo extends StatelessWidget {
  const _AccionDialogo({
    required this.texto,
    required this.alTocar,
    this.color = const Color(0xFF2E2E2E),
  });

  final String texto;
  final VoidCallback alTocar;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: alTocar,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontFamily: regular,
          fontSize: 16,
          height: 24 / 16,
        ),
      ),
    );
  }
}
