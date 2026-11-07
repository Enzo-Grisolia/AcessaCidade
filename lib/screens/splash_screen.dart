import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/app_state.dart';
import 'home_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.state});
  final AppState state;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await Future.wait([
        widget.state.initialize(),
        Future<void>.delayed(const Duration(milliseconds: 1150)),
      ]);
    } catch (_) {
      // Falhas isoladas da preferência não bloqueiam a demonstração do app.
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => widget.state.skipOnboarding
          ? HomeShell(state: widget.state)
          : OnboardingScreen(state: widget.state),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.sea, borderRadius: BorderRadius.circular(28)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/images/acessacidade_logo.png',
                  fit: BoxFit.cover,
                  semanticLabel: 'Logotipo AcessaCidade: pino de localização com rampa',
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text('AcessaCidade', style: TextStyle(
              fontSize: 31, color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            const Text('Um bairro mais acessível começa com informação.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB7CED3), fontSize: 13)),
            const SizedBox(height: 35),
            const SizedBox(height: 28, width: 28,
              child: CircularProgressIndicator(color: Color(0xFF91DED0))),
          ]),
        )),
      );
}
