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
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _correoControlador = TextEditingController();
  final _contrasenaControlador = TextEditingController();
  bool _estaCargando = false;

  @override
  void dispose() {
    _correoControlador.dispose();
    _contrasenaControlador.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final correo = _correoControlador.text.trim();
    final contrasena = _contrasenaControlador.text;
    if (correo.isEmpty || contrasena.isEmpty) {
      _mostrarMensaje('Completa tu correo y contraseña.');
      return;
    }

    setState(() => _estaCargando = true);
    try {
      final respuesta = await AuthService().login(
        LoginRequest(correoElectronico: correo, contrasena: contrasena),
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
            const TopAppBar(titulo: 'Iniciar sesión'),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/icons/icono_usuario_login.png',
                          width: 166,
                          height: 216,
                          semanticLabel: 'Ilustración de usuario',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Input(
                        etiqueta: 'Email',
                        controlador: _correoControlador,
                        placeholder: 'correo@ejemplo.com',
                        tipoTeclado: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      Input(
                        etiqueta: 'Contraseña',
                        controlador: _contrasenaControlador,
                        placeholder: '••••••••',
                        ocultarTexto: true,
                      ),
                      const SizedBox(height: 49),
                      Center(
                        child: BotonGuardar(
                          texto: 'Ingresar',
                          estaCargando: _estaCargando,
                          alPresionar: _iniciarSesion,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '¿No tienes cuenta? ',
                              style: figmaCaption.copyWith(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterView(),
                                ),
                              ),
                              child: Text(
                                'Registrate',
                                style: figmaBody.copyWith(color: auxiliar),
                              ),
                            ),
                          ],
                        ),
                      ),
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
