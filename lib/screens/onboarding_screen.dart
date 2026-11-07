import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/app_state.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.state});
  final AppState state;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _dontShowAgain = false;

  static const _pages = [
    (icon: Icons.map_outlined, title: 'Descubra o que existe no entorno',
      text: 'Veja locais de atendimento e relatos de acessibilidade no mapa '
          'ou em uma lista equivalente, acessível a leitores de tela.'),
    (icon: Icons.edit_location_alt_outlined, title: 'Contribua com a comunidade',
      text: 'Registre uma barreira com categoria, localização, descrição '
          'e perfis de mobilidade afetados.'),
    (icon: Icons.fact_check_outlined, title: 'Da informação à mudança',
      text: 'Confirme se uma barreira ainda existe, consulte fichas de '
          'acessibilidade e acompanhe prioridades do gestor.'),
  ];

  Future<void> _finish() async {
    await widget.state.completeOnboarding(_dontShowAgain);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => HomeShell(state: widget.state),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 18),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.accessible_forward_rounded, color: AppColors.sea),
          const SizedBox(width: 8),
          const Text('AcessaCidade', style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 18)),
          const Spacer(),
          TextButton(onPressed: _finish, child: const Text('Pular')),
        ]),
        Expanded(child: PageView.builder(
          controller: _controller,
          onPageChanged: (value) => setState(() => _page = value),
          itemCount: _pages.length,
          itemBuilder: (_, index) => Column(
            mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 168, height: 168,
                decoration: BoxDecoration(color: AppColors.seaLight,
                  borderRadius: BorderRadius.circular(42)),
                child: Icon(_pages[index].icon, size: 96, color: AppColors.sea),
              ),
              const SizedBox(height: 35),
              Text(_pages[index].title, textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(_pages[index].text, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.5,
                  color: Color(0xFF647782))),
            ],
          ),
        )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int index = 0; index < _pages.length; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              margin: const EdgeInsets.all(4),
              width: index == _page ? 29 : 9, height: 9,
              decoration: BoxDecoration(
                color: index == _page ? AppColors.sea : AppColors.outline,
                borderRadius: BorderRadius.circular(8)),
            ),
        ]),
        const SizedBox(height: 14),
        CheckboxListTile(
          title: const Text('Não mostrar novamente',
              style: TextStyle(fontSize: 14)),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          value: _dontShowAgain,
          onChanged: (value) => setState(() => _dontShowAgain = value ?? false),
        ),
        const SizedBox(height: 7),
        Row(children: [
          if (_page > 0) ...[
            Expanded(child: OutlinedButton(
              onPressed: () => _controller.previousPage(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut),
              child: const Text('Voltar'),
            )),
            const SizedBox(width: 12),
          ],
          Expanded(child: ElevatedButton(
            onPressed: _page == 2 ? _finish : () => _controller.nextPage(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut),
            child: Text(_page == 2 ? 'Começar' : 'Avançar'),
          )),
        ]),
      ]),
    )),
  );
}
