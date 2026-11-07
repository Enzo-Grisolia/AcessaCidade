import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';
import '../core/demo_data.dart';
import '../models/public_place.dart';
import '../services/app_state.dart';
import '../widgets/ui_parts.dart';
import 'incident_detail_screen.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.state, required this.place});
  final AppState state;
  final PublicPlace place;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) {
      final nearby = state.publicIncidents.where((incident) =>
        const Distance()(incident.point, place.point) <= 150).toList();
      final no = place.checklist.values.where((v) => v == false).length;
      final yes = place.checklist.values.where((v) => v == true).length;
      return Scaffold(
        appBar: AppBar(title: const Text('Ficha de acessibilidade')),
        body: ListView(padding: const EdgeInsets.all(17), children: [
          const DemoNotice(compact: true),
          const SizedBox(height: 15),
          Text(place.kind.toUpperCase(), style: const TextStyle(
            color: AppColors.sea, letterSpacing: 1, fontWeight: FontWeight.w800)),
          Text(place.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(place.address),
          const SizedBox(height: 6),
          Text('${formatDistance(DemoData.center, place.point)} do ponto de referência',
            style: const TextStyle(fontSize: 12, color: Color(0xFF647782))),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _CountBox(label: 'Atende', value: '$yes',
                color: AppColors.sea)),
            const SizedBox(width: 9),
            Expanded(child: _CountBox(label: 'Não atende', value: '$no',
                color: AppColors.red)),
          ]),
          const SizedBox(height: 22),
          Text('Resumo para seu perfil',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Card(child: Padding(padding: const EdgeInsets.all(13),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Perfis: ${state.profiles.isEmpty ? 'visão geral' : state.profiles.join(', ')}',
                    style: const TextStyle(color: AppColors.sea,
                      fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  Text(_profileSummary(place, state.profiles),
                      style: const TextStyle(height: 1.5)),
                ],
              ))),
          const SizedBox(height: 22),
          Text('Checklist comunitário',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text('Dados de exemplo, ainda sem validação presencial.',
            style: TextStyle(fontSize: 12, color: Color(0xFF647782))),
          const SizedBox(height: 11),
          Card(child: Column(children: [
            for (final item in place.checklist.entries) ...[
              ListTile(
                leading: Icon(
                  item.value == true ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: item.value == true ? AppColors.sea : AppColors.red,
                ),
                title: Text(item.key),
                subtitle: Text(item.value == true ? 'Sim' : 'Não'),
              ),
              if (item.key != place.checklist.keys.last)
                const Divider(height: 1, indent: 14, endIndent: 14),
            ],
          ])),
          const SizedBox(height: 22),
          Text('Relatos em até 150 m (${nearby.length})',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (nearby.isEmpty)
            const Text('Nenhuma ocorrência nesta área de demonstração.'),
          for (final incident in nearby) ...[
            IncidentCard(incident: incident, onTap: () => Navigator.push(
              context, MaterialPageRoute<void>(builder: (_) =>
                IncidentDetailScreen(state: state, incidentId: incident.id)))),
            const SizedBox(height: 10),
          ],
        ]),
      );
    },
  );
  static String _profileSummary(PublicPlace place, List<String> profiles) {
    final requested = <String>{};
    for (final profile in profiles) {
      requested.addAll(DemoData.checklistByProfile[profile] ?? []);
    }
    if (requested.isEmpty) requested.addAll(place.checklist.keys);
    final issues = place.checklist.entries
        .where((item) => requested.contains(item.key) && item.value == false)
        .map((item) => item.key.toLowerCase()).toList();
    if (issues.isEmpty) {
      return 'Não há pendências registradas no checklist para '
          'o(s) perfil(is) selecionado(s). Isso não comprova acessibilidade do local.';
    }
    return 'Itens marcados como não atendidos: ${issues.join('; ')}. '
        'Dados fictícios; valide presencialmente.';
  }
}

class _CountBox extends StatelessWidget {
  const _CountBox({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
    decoration: BoxDecoration(color: Colors.white,
      border: Border.all(color: AppColors.outline),
      borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 25,
        color: color, fontWeight: FontWeight.w900)),
      Text(label, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}
