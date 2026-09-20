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
    this.iconoInicial,
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
  final IconData? iconoInicial;
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
          style: figmaButton.copyWith(
            color: secundario,
            fontFamily: bold,
            fontSize: 17,
            height: 22 / 17,
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 52,
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
              color: primario,
              fontFamily: semibold,
              fontSize: 16,
              height: 24 / 16,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: iconoInicial == null
                  ? null
                  : Icon(
                      iconoInicial,
                      color: const Color(0xFF4F634A),
                      size: 20,
                    ),
              suffixIcon: unidad == null && iconoFinal == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 8, right: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (unidad != null)
                            Text(
                              unidad!,
                              style: figmaCaption.copyWith(
                                color: textoSecundario,
                                height: 24 / 14,
                              ),
                            ),
                          if (unidad != null && iconoFinal != null)
                            const SizedBox(width: 8),
                          if (iconoFinal != null)
                            Icon(iconoFinal, color: textoSecundario, size: 20),
                        ],
                      ),
                    ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 52,
              ),
              hintStyle: figmaCaption.copyWith(
                color: textoSecundario,
                fontSize: 16,
              ),
              isDense: true,
              filled: true,
              fillColor: superficie,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(
                  color: tieneError ? const Color(0xFFDC1A1D) : bordeSuave,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(
                  color: tieneError ? const Color(0xFFDC1A1D) : primario,
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
