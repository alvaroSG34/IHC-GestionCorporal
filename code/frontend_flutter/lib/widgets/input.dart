import 'package:flutter/material.dart';

import '../consts/styles.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.placeholder,
    this.tipoTeclado,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String? placeholder;
  final TextInputType? tipoTeclado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            color: Color(0xFF2E2E2E),
            fontFamily: regular,
            fontSize: 16,
            height: 24 / 16,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controlador,
            keyboardType: tipoTeclado,
            style: const TextStyle(
              color: Color(0xFF616161),
              fontFamily: regular,
              fontSize: 16,
              height: 24 / 16,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: Color(0xFF616161),
                fontFamily: regular,
                fontSize: 16,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF616161)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF616161)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
