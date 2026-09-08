import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/usuario.dart';
import '../../services/session_service.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';
import '../autenticacion/login_view.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final _correoControlador = TextEditingController();
  final _fechaNacimientoControlador = TextEditingController();
  final _telefonoControlador = TextEditingController();
  final _profesionControlador = TextEditingController();
  final _clinicaControlador = TextEditingController();
  bool _cerrandoSesion = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final usuario = await SessionService().obtenerUsuario();
    if (!mounted) return;

    _asignarDatos(usuario);
  }

  void _asignarDatos(Usuario? usuario) {
    _correoControlador.text = usuario?.correoElectronico ?? 'No disponible';
    _fechaNacimientoControlador.text = usuario == null
        ? 'No disponible'
        : _formatearFecha(usuario.fechaNacimiento);
    _telefonoControlador.text = usuario?.telefono ?? 'No registrado';
    _profesionControlador.text = usuario?.profesion ?? 'No disponible';
    _clinicaControlador.text = usuario?.clinica ?? 'No disponible';
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  Future<void> _cerrarSesion() async {
    setState(() => _cerrandoSesion = true);
    await SessionService().cerrarSesion();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _correoControlador.dispose();
    _fechaNacimientoControlador.dispose();
    _telefonoControlador.dispose();
    _profesionControlador.dispose();
    _clinicaControlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopAppBar(titulo: 'Perfil'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Datos básicos',
                  style: figmaBody.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 16),
                Input(
                  etiqueta: 'Email',
                  controlador: _correoControlador,
                  soloLectura: true,
                ),
                const SizedBox(height: 16),
                Input(
                  etiqueta: 'Fecha de nacimiento',
                  controlador: _fechaNacimientoControlador,
                  soloLectura: true,
                ),
                const SizedBox(height: 16),
                Input(
                  etiqueta: 'Teléfono',
                  controlador: _telefonoControlador,
                  soloLectura: true,
                ),
                const SizedBox(height: 16),
                Input(
                  etiqueta: 'Profesión',
                  controlador: _profesionControlador,
                  soloLectura: true,
                ),
                const SizedBox(height: 16),
                Input(
                  etiqueta: 'Clínica',
                  controlador: _clinicaControlador,
                  soloLectura: true,
                ),
                const SizedBox(height: 43),
                Center(
                  child: BotonGuardar(
                    texto: 'Cerrar sesión',
                    estaCargando: _cerrandoSesion,
                    alPresionar: _cerrandoSesion ? null : _cerrarSesion,
                    colorFondo: error,
                    colorTexto: blanco,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
