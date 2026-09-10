import 'package:flutter/material.dart';

import 'services/session_service.dart';
import 'views/autenticacion/login_view.dart';
import 'views/home_view/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tieneSesion = await SessionService().haySesion();
  runApp(MyApp(tieneSesion: tieneSesion));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.tieneSesion = false});

  final bool tieneSesion;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión corporal',
      home: tieneSesion ? const HomeView() : const LoginView(),
    );
  }
}
