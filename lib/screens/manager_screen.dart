import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/demo_data.dart';
import '../models/incident.dart';
import '../services/app_state.dart';
import '../services/pdf_report_service.dart';
import '../services/priority_service.dart';
import '../widgets/ui_parts.dart';
import 'incident_detail_screen.dart';

class ManagerScreen extends StatelessWidget {
  const ManagerScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) {
      final ranked = PriorityService.ranked(
        state.publicIncidents,
        DemoData.places,
      );
      final confirmed = state.publicIncidents
          .where((i) => i.status == IncidentStatus.confirmed)
          .length;
      final resolved = state.publicIncidents
          .where((i) => i.status == IncidentStatus.resolved)
          .length;
      final active = state.publicIncidents
          .where((i) => i.status != IncidentStatus.resolved)
          .length;
      return LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: EdgeInsets.fromLTRB(
            constraints.maxWidth >= 790 ? 32 : 16,
            27,
            constraints.maxWidth >= 790 ? 32 : 16,
            32,
          ),
          children: [
            const PageHeading(
              eyebrow: 'Inteligência territorial',
              title: 'Painel de prioridades',
              subtitle:
                  'Transforme relatos confirmados em uma fila '
                  'explicável de intervenções.',
            ),
            const SizedBox(height: 16),
            const DemoNotice(compact: true),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _Kpi(
                    label: 'Em aberto',
                    value: '$active',
                    color: AppColors.amber,
                    icon: Icons.warning_amber_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Kpi(
                    label: 'Confirmados',
                    value: '$confirmed',
                    color: AppColors.red,
                    icon: Icons.verified_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Kpi(
                    label: 'Resolvidos',
                    value: '$resolved',
                    color: AppColors.sea,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            LayoutBuilder(
              builder: (context, c) {
                final cards = <Widget>[
                  _InsightCard(
                    label: 'INSIGHT IA 1',
                    title: 'Foco imediato sugerido',
                    body: ranked.isEmpty
                        ? 'Nenhuma ocorrência ativa.'
                        : 'Priorizar “${ranked.first.title}” pela combinação de severidade, confirmações e proximidade.',
                  ),
                  _InsightCard(
                    label: 'INSIGHT IA 2',
                    title: 'Padrão predominante',
                    body:
                        'Acompanhe as barreiras mais recorrentes e concentre ações nas categorias com mais relatos.',
                  ),
                  _InsightCard(
                    label: 'INSIGHT IA 3',
                    title: 'Perfis impactados',
                    body:
                        '$active relatos ativos. Cruze a categoria do problema com os perfis afetados para orientar decisões.',
                  ),
                ];
                if (c.maxWidth < 650) {
                  return Column(
                    children: [
                      for (final card in cards) ...[
                        card,
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 13),
            const Text(
              'Insights demonstrativos por regras; não são resultados de IA generativa.',
              style: TextStyle(fontSize: 11, color: Color(0xFF647782)),
            ),
            const SizedBox(height: 23),
            Text(
              'Fila de moderação (${state.pendingIncidents.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 7),
            const Text(
              'Aprovação ilustrativa: nesta demo, o gestor não possui login próprio. '
              'Em produção, somente perfis autorizados poderão moderar.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 9),
            if (state.pendingIncidents.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum relato aguardando aprovação.'),
                ),
              ),
            for (final incident in state.pendingIncidents) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(incident.category),
                      const SizedBox(height: 5),
                      Text(
                        incident.address,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (incident.photoBytes != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            incident.photoBytes!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          'Descrição acessível: ${incident.photoDescription ?? 'Não fornecida'}',
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Chip(
                        avatar: Icon(Icons.auto_awesome, size: 17),
                        label: Text(
                          'IA: demonstração sem análise real da foto',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                state.moderateIncident(incident.id, true),
                            icon: const Icon(Icons.check),
                            label: const Text('Aprovar'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                state.moderateIncident(incident.id, false),
                            icon: const Icon(Icons.close),
                            label: const Text('Rejeitar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 9),
            ],
            const SizedBox(height: 17),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await PdfReportService.export(state.publicIncidents);
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Não foi possível gerar o PDF: $error'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Exportar relatório demonstrativo em PDF'),
              ),
            ),
            const SizedBox(height: 23),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ranking de prioridade',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Icon(Icons.trending_up, color: AppColors.sea),
              ],
            ),
            const SizedBox(height: 7),
            const Text(
              'Critério: severidade × confirmações × proximidade '
              'de serviço público × recência.',
              style: TextStyle(fontSize: 12, color: Color(0xFF647782)),
            ),
            const SizedBox(height: 12),
            for (int index = 0; index < ranked.length; index++) ...[
              _RankingCard(
                index: index + 1,
                incident: ranked[index],
                score: PriorityService.score(ranked[index], DemoData.places),
                reason: PriorityService.reason(ranked[index], DemoData.places),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => IncidentDetailScreen(
                      state: state,
                      incidentId: ranked[index].id,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Restaurar dados de demonstração?'),
                    content: const Text(
                      'Isso substituirá seus relatos e votos locais '
                      'pelos exemplos iniciais.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Restaurar'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) await state.restoreDemoIncidents();
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Restaurar dados da demonstração'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.outline),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 29,
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.index,
    required this.incident,
    required this.score,
    required this.reason,
    required this.onTap,
  });
  final int index;
  final Incident incident;
  final double score;
  final String reason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: AppColors.seaLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$indexº',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.sea,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  StatusChip(status: incident.status),
                  const SizedBox(height: 7),
                  Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF647782),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              score.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.sea,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.label,
    required this.title,
    required this.body,
  });
  final String label;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 155),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.outline),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.sea,
            fontSize: 10,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 9),
        Text(
          body,
          style: const TextStyle(
            height: 1.5,
            fontSize: 12,
            color: Color(0xFF647782),
          ),
        ),
      ],
    ),
  );
}
