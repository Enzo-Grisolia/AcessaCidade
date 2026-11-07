import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/incident.dart';
import '../services/app_state.dart';
import '../widgets/profile_sheet.dart';
import '../widgets/ui_parts.dart';

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({super.key, required this.state, required this.incidentId});
  final AppState state;
  final String incidentId;

  Future<void> _castVote(BuildContext context, String vote) async {
    if (!state.signedIn) {
      await showProfileSheet(context, state);
      if (!state.signedIn) return;
    }
    final success = await state.vote(incidentId, vote);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success
        ? 'Sua confirmação de demonstração foi registrada.'
        : 'Não foi possível registrar o voto.')));
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) {
      final matches = state.incidents.where((item) => item.id == incidentId);
      if (matches.isEmpty) {
        return const Scaffold(body: Center(child: Text('Relato não encontrado.')));
      }
      final incident = matches.first;
      final readableDate = '${incident.createdAt.day.toString().padLeft(2, '0')}/'
          '${incident.createdAt.month.toString().padLeft(2, '0')}/'
          '${incident.createdAt.year}';
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da barreira')),
        body: ListView(padding: const EdgeInsets.all(17), children: [
          const DemoNotice(compact: true),
          const SizedBox(height: 16),
          if (incident.moderation == ModerationStatus.pending)
            const Chip(avatar: Icon(Icons.hourglass_top),
              label: Text('Aguardando validação do gestor'))
          else if (incident.moderation == ModerationStatus.rejected)
            const Chip(avatar: Icon(Icons.block), label: Text('Relato rejeitado'))
          else StatusChip(status: incident.status),
          const SizedBox(height: 12),
          Text(incident.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(incident.category, style: const TextStyle(
            color: AppColors.sea, fontWeight: FontWeight.w800)),
          const SizedBox(height: 17),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('O que foi relatado',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 9),
              Text(incident.description),
              const SizedBox(height: 15),
              const Divider(),
              Row(children: [
                const Icon(Icons.place_outlined, color: AppColors.sea),
                const SizedBox(width: 7),
                Expanded(child: Text(incident.address,
                    style: const TextStyle(fontSize: 12))),
              ]),
              const SizedBox(height: 7),
              Text('Registrado em $readableDate',
                style: const TextStyle(fontSize: 12, color: Color(0xFF647782))),
              Text('Coordenadas: ${incident.point.latitude.toStringAsFixed(5)}, '
                  '${incident.point.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF647782))),
            ]),
          )),
          if (incident.photoBytes != null) ...[
            const SizedBox(height: 15),
            ClipRRect(borderRadius: BorderRadius.circular(16),
              child: Semantics(
                label: incident.photoDescription ?? 'Foto anexada ao relato',
                image: true,
                child: Image.memory(incident.photoBytes!, height: 220,
                  fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            const SizedBox(height: 5),
            Text('Descrição da foto: ${incident.photoDescription ?? 'Não informada'}',
              style: const TextStyle(fontSize: 12)),
          ],
          const SizedBox(height: 18),
          Text('Perfis afetados', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 9),
          Wrap(spacing: 7, runSpacing: 7,
            children: incident.affectedProfiles.map((profile) =>
              Chip(label: Text(profile))).toList()),
          const SizedBox(height: 18),
          if (incident.isPublic) Text('Validação da comunidade',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 7),
          if (incident.isPublic) Text('${incident.existsVotes} confirmação(ões) de existência • '
              '${incident.resolvedVotes} indicação(ões) de resolução',
            style: const TextStyle(fontSize: 13, color: Color(0xFF647782))),
          const SizedBox(height: 13),
          if (incident.isPublic) Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _castVote(context, 'exists'),
              icon: const Icon(Icons.report_problem_outlined, size: 18),
              label: const Text('Ainda existe', textAlign: TextAlign.center),
            )),
            const SizedBox(width: 9),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _castVote(context, 'resolved'),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Foi resolvido', textAlign: TextAlign.center),
            )),
          ]),
          const SizedBox(height: 12),
          const Text('Status: duas confirmações de usuários distintos passam o relato '
              'para Confirmado; dois votos de resolução passam para Resolvido. '
              'No protótipo, a identidade é apenas local e demonstrativa.',
            style: TextStyle(fontSize: 11, color: Color(0xFF647782))),
          const SizedBox(height: 18),
        ]),
      );
    },
  );
}
