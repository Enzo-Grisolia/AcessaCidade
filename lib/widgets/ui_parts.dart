import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';
import '../core/demo_data.dart';
import '../models/incident.dart';
import '../models/public_place.dart';

String formatDistance(LatLng from, LatLng to) {
  final meters = const Distance()(from, to);
  return meters < 1000 ? '${meters.round()} m' : '${(meters / 1000).toStringAsFixed(1)} km';
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 14, vertical: compact ? 7 : 11),
        decoration: BoxDecoration(
          color: AppColors.amberLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF4D9A8)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline, color: AppColors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'DEMONSTRAÇÃO: locais e relatos fictícios. Não use para decisões reais de deslocamento.',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
      );
}

class PageHeading extends StatelessWidget {
  const PageHeading({super.key, required this.eyebrow, required this.title,
    required this.subtitle});
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.sea, fontSize: 11,
                  letterSpacing: 1.2, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 7),
          Text(subtitle, style: const TextStyle(color: Color(0xFF647782), height: 1.35)),
        ],
      );
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (text, icon, color, bg) = switch (status) {
      IncidentStatus.newReport => ('Novo', Icons.fiber_new_rounded,
        AppColors.amber, AppColors.amberLight),
      IncidentStatus.confirmed => ('Confirmado', Icons.verified_outlined,
        AppColors.red, AppColors.redLight),
      IncidentStatus.resolved => ('Resolvido', Icons.check_circle_outline,
        AppColors.sea, AppColors.seaLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(fontWeight: FontWeight.w800,
          color: color, fontSize: 11)),
      ]),
    );
  }
}

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, required this.onTap,
      this.reference = DemoData.center});
  final Incident incident;
  final VoidCallback onTap;
  final LatLng reference;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '${incident.title}. ${incident.address}. '
            'Distância do ponto de referência ${formatDistance(reference, incident.point)}. '
            '${incident.category}. ${incident.status.name}.',
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(incident.title,
                      style: Theme.of(context).textTheme.titleMedium)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: AppColors.sea),
                ]),
                const SizedBox(height: 9),
                Wrap(spacing: 8, runSpacing: 7, children: [
                  StatusChip(status: incident.status),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.background,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(incident.category, style: const TextStyle(
                        fontSize: 11, color: AppColors.ink, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 11),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.place_outlined, size: 17, color: AppColors.sea),
                  const SizedBox(width: 6),
                  Expanded(child: Text(incident.address,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF647782)))),
                ]),
                const SizedBox(height: 7),
                Text('${formatDistance(reference, incident.point)} do ponto de referência  •  '
                    '${incident.existsVotes} confirmação(ões)',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF647782))),
              ]),
            ),
          ),
        ),
      );
}

class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.place, required this.onTap,
    required this.activeIssues, this.reference = DemoData.center});
  final PublicPlace place;
  final int activeIssues;
  final VoidCallback onTap;
  final LatLng reference;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '${place.kind}, ${place.name}, ${place.address}. '
            'Distância do ponto de referência: ${formatDistance(reference, place.point)}. '
            '$activeIssues relato(s) ativo(s) no entorno.',
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: AppColors.seaLight,
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(switch (place.kind) {
                    'UBS' => Icons.local_hospital_outlined,
                    'Escola' => Icons.school_outlined,
                    'Parada' => Icons.directions_bus_outlined,
                    _ => Icons.account_balance_outlined,
                  }, color: AppColors.sea),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.kind.toUpperCase(), style: const TextStyle(
                        fontSize: 10, color: AppColors.sea,
                        fontWeight: FontWeight.w800, letterSpacing: 0.7)),
                      Text(place.name, style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(place.address, style: const TextStyle(
                          fontSize: 11, color: Color(0xFF647782))),
                      const SizedBox(height: 4),
                      Text('${formatDistance(reference, place.point)} da referência · '
                          '$activeIssues alerta(s) ativo(s)',
                          style: const TextStyle(fontSize: 11,
                              color: AppColors.amber, fontWeight: FontWeight.w700)),
                    ])),
                const Icon(Icons.chevron_right, color: AppColors.sea),
              ]),
            ),
          ),
        ),
      );
}
