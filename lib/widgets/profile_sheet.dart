import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/demo_data.dart';
import '../services/app_state.dart';

Future<void> showProfileSheet(BuildContext context, AppState state) async {
  final controller = TextEditingController(text: state.displayName ?? '');
  final selected = <String>{...state.profiles};
  bool consent = state.profiles.isNotEmpty;
  try {
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20, 6, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meu perfil', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text('Acesso livre para consulta. Um nome de demonstração é '
                    'solicitado para publicar e confirmar relatos.'),
                const SizedBox(height: 17),
                TextField(
                  controller: controller, maxLength: 45,
                  decoration: const InputDecoration(
                    labelText: 'Nome de demonstração (opcional)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 9),
                const Text('Como você se desloca? (opcional)',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Este filtro representa necessidades de deslocamento, '
                    'não diagnósticos. Você pode desmarcar tudo.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF647782))),
                for (final profile in DemoData.profiles)
                  CheckboxListTile(
                    dense: true, contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.sea,
                    value: selected.contains(profile),
                    onChanged: (value) => setModalState(() {
                      if (value == true) {
                        selected.add(profile);
                      } else {
                        selected.remove(profile);
                      }
                    }),
                    title: Text(profile),
                  ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Concordo em armazenar minhas preferências '
                      'de mobilidade neste dispositivo para filtrar a consulta.',
                      style: TextStyle(fontSize: 12)),
                  subtitle: const Text('Consentimento opcional, necessário '
                      'somente ao selecionar perfis. Desmarque perfis para revogar.'),
                  value: consent,
                  onChanged: (value) => setModalState(() => consent = value ?? false),
                ),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar preferências'),
                    onPressed: () async {
                      if (selected.isNotEmpty && !consent) {
                        ScaffoldMessenger.of(modalContext).showSnackBar(
                          const SnackBar(content: Text('Marque o consentimento '
                              'ou desmarque os perfis antes de salvar.')));
                        return;
                      }
                      await state.saveProfile(controller.text, selected.toList());
                      if (modalContext.mounted) Navigator.of(modalContext).pop();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Atenção: não é autenticação real. Antes de publicar, '
                    'integrar login seguro, autorização e LGPD.',
                    style: TextStyle(color: AppColors.amber, fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  } finally {
    controller.dispose();
  }
}
