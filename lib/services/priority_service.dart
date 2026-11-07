import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../models/incident.dart';
import '../models/public_place.dart';

/// Proposta do documento, página 7:
/// P = S × (1 + ln(1 + C)) × (1 + E) × R.
class PriorityService {
  static const Map<String, int> severityByCategory = {
    'Calçada danificada': 2,
    'Rampa irregular': 3,
    'Piso tátil ausente': 3,
    'Obstrução na calçada': 2,
    'Semáforo sem sinal sonoro': 3,
    'Entrada sem acesso': 3,
  };

  static double score(Incident incident, List<PublicPlace> places,
      {DateTime? now}) {
    if (incident.status == IncidentStatus.resolved) return 0;
    final s = severityByCategory[incident.category] ?? 1;
    final c = incident.existsVotes;
    double e = 0;
    const distance = Distance();
    for (final place in places) {
      if (distance(incident.point, place.point) > 200) continue;
      final bonus = switch (place.kind) {
        'UBS' => 1.0,
        'Escola' => 0.7,
        'Parada' => 0.7,
        _ => 0.4,
      };
      if (bonus > e) e = bonus;
    }
    final age = (now ?? DateTime.now()).difference(incident.createdAt).inDays;
    final r = age <= 30 ? 1.0 : 0.6;
    return s * (1 + math.log(1 + c)) * (1 + e) * r;
  }

  static List<Incident> ranked(List<Incident> incidents, List<PublicPlace> places) {
    return [...incidents]..sort((a, b) =>
        score(b, places).compareTo(score(a, places)));
  }

  static String reason(Incident incident, List<PublicPlace> places) {
    const distance = Distance();
    PublicPlace? nearest;
    double nearestMeters = double.infinity;
    for (final place in places) {
      final meters = distance(incident.point, place.point);
      if (meters < nearestMeters) {
        nearest = place;
        nearestMeters = meters;
      }
    }
    final proximity = nearestMeters <= 200 && nearest != null
        ? ', a ${nearestMeters.round()} m de ${nearest.kind}'
        : ', sem serviço público a até 200 m';
    return '${incident.category}, ${incident.existsVotes} confirmação(ões)$proximity';
  }
}
