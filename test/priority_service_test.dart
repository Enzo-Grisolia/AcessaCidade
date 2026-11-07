import 'package:acessacidade/core/demo_data.dart';
import 'package:acessacidade/models/incident.dart';
import 'package:acessacidade/services/priority_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('relato pendente só se torna público após aprovação', () {
    final old = DemoData.seedIncidents().first;
    final pending = old.copyWith(moderation: ModerationStatus.pending);
    expect(pending.isPublic, isFalse);
    expect(pending.copyWith(moderation: ModerationStatus.approved).isPublic, isTrue);
  });

  test('problema resolvido não ganha prioridade', () {
    final resolved = DemoData.seedIncidents()
        .firstWhere((item) => item.status == IncidentStatus.resolved);
    expect(PriorityService.score(resolved, DemoData.places), 0);
  });

  test('ranking ordena da maior para a menor pontuação', () {
    final ranked = PriorityService.ranked(DemoData.seedIncidents(), DemoData.places);
    for (int index = 1; index < ranked.length; index++) {
      expect(
        PriorityService.score(ranked[index - 1], DemoData.places),
        greaterThanOrEqualTo(PriorityService.score(ranked[index], DemoData.places)),
      );
    }
  });

  test('dois relatos de usuários diferentes confirmam a barreira', () {
    final old = DemoData.seedIncidents().firstWhere((item) => item.id == 'd3');
    expect(old.status, IncidentStatus.newReport);
    final confirmed = old.withVote('outro-usuario', 'exists');
    expect(confirmed.status, IncidentStatus.confirmed);
  });

  test('votar duas vezes com o mesmo nome não conta como dois votos', () {
    final old = DemoData.seedIncidents().firstWhere((item) => item.id == 'd3');
    final once = old.withVote('outra-pessoa', 'exists');
    final twice = once.withVote('outra-pessoa', 'exists');
    expect(once.existsVotes, twice.existsVotes);
  });
}
