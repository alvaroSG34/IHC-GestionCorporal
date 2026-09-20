import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../consts/styles.dart';

class TopAppBar extends StatelessWidget {
  const TopAppBar({
    super.key,
    this.titulo,
    this.alVolver,
    this.alAccion,
    this.textoAccion,
    this.altura = 64,
    this.tamanoTitulo,
    this.diametroAccionCircular = 40,
    this.elevacionAccionCircular = false,
  });

  final String? titulo;
  final VoidCallback? alVolver;
  final VoidCallback? alAccion;
  final String? textoAccion;
  final double altura;
  final double? tamanoTitulo;
  final double diametroAccionCircular;
  final bool elevacionAccionCircular;

  @override
  Widget build(BuildContext context) {
    final muestraVolver = alVolver != null;
    final muestraAccion = alAccion != null;
    final usaAccionCircular = muestraAccion && textoAccion == null;
    final altoAccion = usaAccionCircular ? diametroAccionCircular : 32.0;

    return SizedBox(
      height: altura,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: (altura - altoAccion) / 2,
        ),
        child: Row(
          children: [
            if (muestraVolver) ...[
              _AccionCabecera(
                etiquetaSemantica: 'Volver',
                simbolo: '‹',
                tamanoFuente: 32,
                color: textoSecundario,
                alTocar: alVolver!,
              ),
              const SizedBox(width: 16),
            ],
            if (titulo != null)
              Expanded(
                child: Text(
                  titulo!,
                  style: figmaHeading.copyWith(
                    color: secundario,
                    fontSize: tamanoTitulo,
                    height: tamanoTitulo == 28 ? 34 / 28 : 32 / 24,
                  ),
                ),
              )
            else
              const Spacer(),
            if (muestraAccion) ...[
              if (titulo != null || muestraVolver) const SizedBox(width: 16),
              _AccionCabecera(
                etiquetaSemantica: textoAccion ?? 'Agregar',
                simbolo: textoAccion ?? '+',
                tamanoFuente: textoAccion == null
                    ? (diametroAccionCircular == 48 ? 34 : 28)
                    : 16,
                color: const Color(0xFF2E2E2E),
                ancho: textoAccion == null ? diametroAccionCircular : 60,
                fondo: textoAccion == null ? auxiliar : null,
                sombra: usaAccionCircular && elevacionAccionCircular,
                alTocar: alAccion!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccionCabecera extends StatelessWidget {
  const _AccionCabecera({
    required this.etiquetaSemantica,
    required this.simbolo,
    required this.tamanoFuente,
    required this.color,
    this.ancho = 24,
    this.fondo,
    this.sombra = false,
    required this.alTocar,
  });

  final String etiquetaSemantica;
  final String simbolo;
  final double tamanoFuente;
  final Color color;
  final double ancho;
  final Color? fondo;
  final bool sombra;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiquetaSemantica,
      child: InkWell(
        onTap: alTocar,
        child: Container(
          width: ancho,
          height: fondo == null ? 32 : ancho,
          decoration: fondo == null
              ? null
              : BoxDecoration(
                  color: fondo,
                  shape: BoxShape.circle,
                  boxShadow: sombra
                      ? const [
                          BoxShadow(
                            color: Color.fromRGBO(48, 59, 28, 0.18),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
          child: Center(
            child: Text(
              etiquetaSemantica == 'Volver'
                  ? String.fromCharCode(0x2039)
                  : simbolo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: tamanoFuente,
                height: 32 / tamanoFuente,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
