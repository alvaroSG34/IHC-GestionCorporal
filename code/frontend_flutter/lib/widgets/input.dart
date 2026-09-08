import 'package:flutter/material.dart';

import '../consts/styles.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.placeholder,
    this.tipoTeclado,
    this.soloLectura = false,
    this.unidad,
    this.mensajeError,
    this.nodoFoco,
    this.alTocar,
    this.iconoFinal,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String? placeholder;
  final TextInputType? tipoTeclado;
  final bool soloLectura;
  final String? unidad;
  final String? mensajeError;
  final FocusNode? nodoFoco;
  final VoidCallback? alTocar;
  final IconData? iconoFinal;

  @override
  Widget build(BuildContext context) {
    final tieneError = mensajeError?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          etiqueta,
          style: figmaBody.copyWith(color: const Color(0xFF2E2E2E)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controlador,
            focusNode: nodoFoco,
            keyboardType: tipoTeclado,
            readOnly: soloLectura,
            onTap: alTocar,
            style: const TextStyle(
              color: Color(0xFF616161),
              fontFamily: regular,
              fontSize: 16,
              height: 24 / 16,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              suffixText: unidad,
              suffixIcon: iconoFinal == null
                  ? null
                  : Icon(iconoFinal, color: const Color(0xFF616161), size: 20),
              hintStyle: const TextStyle(
                color: Color(0xFF616161),
                fontFamily: regular,
                fontSize: 16,
              ),
              suffixStyle: const TextStyle(
                color: Color(0xFF616161),
                fontFamily: regular,
                fontSize: 14,
                height: 24 / 14,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                  color: tieneError
                      ? const Color(0xFFDC1A1D)
                      : const Color(0xFF616161),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                  color: tieneError
                      ? const Color(0xFFDC1A1D)
                      : const Color(0xFF4C34D9),
                ),
              ),
            ),
          ),
        ),
        if (tieneError) ...[
          const SizedBox(height: 8),
          Text(
            mensajeError!,
            style: const TextStyle(
              color: Color(0xFFDC1A1D),
              fontFamily: regular,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
        ],
      ],
    );
  }
}
