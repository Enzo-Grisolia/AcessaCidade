import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AcessaCidadeApp());
}

class AcessaCidadeApp extends StatelessWidget {
  AcessaCidadeApp({super.key});
  final AppState appState = AppState();

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AcessaCidade • Global Solution',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: SplashScreen(state: appState),
      );
}
