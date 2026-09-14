import 'package:flutter/material.dart';

import '../consts/colors.dart';
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
    this.alCambiar,
    this.iconoFinal,
    this.ocultarTexto = false,
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
  final ValueChanged<String>? alCambiar;
  final IconData? iconoFinal;
  final bool ocultarTexto;

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
            obscureText: ocultarTexto,
            enableSuggestions: !ocultarTexto,
            autocorrect: !ocultarTexto,
            onTap: alTocar,
            onChanged: alCambiar,
            style: figmaCaption.copyWith(
              color: textoSecundario,
              fontSize: 16,
              height: 24 / 16,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              suffixText: unidad,
              suffixIcon: iconoFinal == null
                  ? null
                  : Icon(iconoFinal, color: textoSecundario, size: 20),
              hintStyle: figmaCaption.copyWith(
                color: textoSecundario,
                fontSize: 16,
              ),
              suffixStyle: figmaCaption.copyWith(
                color: textoSecundario,
                height: 24 / 14,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                  color: tieneError ? const Color(0xFFDC1A1D) : textoSecundario,
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
            style: figmaCaption.copyWith(
              color: const Color(0xFFDC1A1D),
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
        ],
      ],
    );
  }
}
