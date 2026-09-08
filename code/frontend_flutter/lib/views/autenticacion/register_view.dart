import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/usuario.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/input.dart';
import '../../widgets/top_app_bar.dart';
import '../home_view/home_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _correoControlador = TextEditingController();
  final _contrasenaControlador = TextEditingController();
  final _fechaNacimientoControlador = TextEditingController();
  final _telefonoControlador = TextEditingController();
  final _profesionControlador = TextEditingController();
  final _clinicaControlador = TextEditingController();
  DateTime? _fechaNacimiento;
  bool _estaCargando = false;

  @override
  void dispose() {
    _correoControlador.dispose();
    _contrasenaControlador.dispose();
    _fechaNacimientoControlador.dispose();
    _telefonoControlador.dispose();
    _profesionControlador.dispose();
    _clinicaControlador.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (fecha == null) return;

    setState(() {
      _fechaNacimiento = fecha;
      _fechaNacimientoControlador.text =
          '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    });
  }

  Future<void> _registrar() async {
    final correo = _correoControlador.text.trim();
    final contrasena = _contrasenaControlador.text;
    final profesion = _profesionControlador.text.trim();
    final clinica = _clinicaControlador.text.trim();
    if (correo.isEmpty ||
        contrasena.isEmpty ||
        _fechaNacimiento == null ||
        profesion.isEmpty ||
        clinica.isEmpty) {
      _mostrarMensaje('Completa los campos obligatorios.');
      return;
    }

    setState(() => _estaCargando = true);
    try {
      final respuesta = await AuthService().registrar(
        RegistroRequest(
          correoElectronico: correo,
          contrasena: contrasena,
          fechaNacimiento: _fechaNacimiento!,
          telefono: _telefonoControlador.text.trim().isEmpty
              ? null
              : _telefonoControlador.text.trim(),
          profesion: profesion,
          clinica: clinica,
        ),
      );
      await SessionService().guardarToken(respuesta.accessToken);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeView()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _mostrarMensaje(error.toString().replaceFirst('Exception: ', ''));
      setState(() => _estaCargando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            const TopAppBar(titulo: 'Crear Cuenta'),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Input(
                        etiqueta: 'Email',
                        controlador: _correoControlador,
                        placeholder: 'correo@ejemplo.com',
                        tipoTeclado: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      Input(
                        etiqueta: 'Contraseña',
                        controlador: _contrasenaControlador,
                        placeholder: '••••••••',
                        ocultarTexto: true,
                      ),
                      const SizedBox(height: 24),
                      Input(
                        etiqueta: 'Fecha de nacimiento',
                        controlador: _fechaNacimientoControlador,
                        placeholder: 'Selecciona una fecha',
                        soloLectura: true,
                        alTocar: _seleccionarFecha,
                        iconoFinal: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 24),
                      Input(
                        etiqueta: 'Teléfono',
                        controlador: _telefonoControlador,
                        placeholder: '00000000',
                        tipoTeclado: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      Input(
                        etiqueta: 'Profesión',
                        controlador: _profesionControlador,
                        placeholder: 'Ej. Nutricionista',
                      ),
                      const SizedBox(height: 24),
                      Input(
                        etiqueta: 'Clínica',
                        controlador: _clinicaControlador,
                        placeholder: 'Ej. Clínica Central',
                      ),
                      const SizedBox(height: 33),
                      Center(
                        child: BotonGuardar(
                          texto: 'Registrarme',
                          estaCargando: _estaCargando,
                          alPresionar: _registrar,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Wrap(
                          children: [
                            Text(
                              'Ya tienes Cuenta? ',
                              style: figmaCaption.copyWith(color: secundario),
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text(
                                'Inicia Sesion',
                                style: figmaCaption.copyWith(color: auxiliar),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
