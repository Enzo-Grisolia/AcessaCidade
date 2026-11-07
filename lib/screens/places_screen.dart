import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';
import '../core/demo_data.dart';
import '../models/incident.dart';
import '../models/public_place.dart';
import '../services/app_state.dart';
import '../widgets/ui_parts.dart';
import 'place_detail_screen.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key, required this.state});
  final AppState state;
  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  String _search = '';
  String _type = 'Todos';
  static const types = ['Todos', 'UBS', 'Escola', 'Parada', 'CRAS', 'Centro público'];

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.state,
    builder: (context, _) => LayoutBuilder(builder: (context, constraints) {
      final places = DemoData.places.where((p) =>
        (_type == 'Todos' || p.kind == _type) &&
        '${p.name} ${p.kind} ${p.address}'.toLowerCase()
          .contains(_search.toLowerCase())).toList();
      places.sort((a, b) => const Distance()(DemoData.center, a.point)
          .compareTo(const Distance()(DemoData.center, b.point)));
      final cols = constraints.maxWidth >= 1050 ? 3
          : constraints.maxWidth >= 650 ? 2 : 1;
      final desktop = constraints.maxWidth >= 790;
      return ListView(
        padding: EdgeInsets.fromLTRB(desktop ? 32 : 16, 27, desktop ? 32 : 16, 32),
        children: [
          const PageHeading(eyebrow: 'Consulta por serviço', title: 'Locais públicos',
            subtitle: 'Conheça a acessibilidade antes de sair de casa.'),
          const SizedBox(height: 18),
          TextField(
            onChanged: (text) => setState(() => _search = text),
            decoration: const InputDecoration(labelText: 'Buscar serviço',
              hintText: 'Buscar serviço ou região', prefixIcon: Icon(Icons.search)),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Row(children: [for (final type in types)
              Padding(padding: const EdgeInsets.only(right: 7),
                child: ChoiceChip(label: Text(type),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type))),
            ])),
          const SizedBox(height: 14),
          Text('${places.length} locais   •   Por proximidade à referência',
            style: const TextStyle(fontSize: 12, color: Color(0xFF647782))),
          const SizedBox(height: 13),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final type in types.skip(1)) _CountPill(
              label: '$type  ·  ${DemoData.places.where((p) => p.kind == type).length}'),
          ]),
          const SizedBox(height: 16),
          if (places.isEmpty) const Center(child: Padding(
            padding: EdgeInsets.all(26), child: Text('Nenhum local encontrado.'))),
          if (places.isNotEmpty) GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: places.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols, mainAxisSpacing: 12, crossAxisSpacing: 12,
              mainAxisExtent: 177,
            ),
            itemBuilder: (_, index) {
              final place = places[index];
              return _PublicPlaceCard(place: place,
                nearby: widget.state.publicIncidents.where((incident) =>
                  incident.status != IncidentStatus.resolved &&
                  const Distance()(incident.point, place.point) <= 150).length,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => PlaceDetailScreen(state: widget.state, place: place))));
            },
          ),
          const SizedBox(height: 16),
          const DemoNotice(compact: true),
        ],
      );
    }),
  );
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(color: Colors.white,
      border: Border.all(color: AppColors.outline),
      borderRadius: BorderRadius.circular(30)),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800,
      fontSize: 11, color: Color(0xFF526A72))));
}

class _PublicPlaceCard extends StatelessWidget {
  const _PublicPlaceCard({required this.place, required this.nearby, required this.onTap});
  final PublicPlace place;
  final int nearby;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(18),
    child: Padding(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(color: AppColors.seaLight,
              borderRadius: BorderRadius.circular(13)),
            child: Icon(switch (place.kind) {
              'UBS' => Icons.local_hospital_outlined,
              'Escola' => Icons.school_outlined,
              'Parada' => Icons.directions_bus_outlined,
              _ => Icons.location_city_outlined,
            }, color: AppColors.sea)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place.kind.toUpperCase(), style: const TextStyle(
              color: AppColors.sea, letterSpacing: 1.1,
              fontSize: 10, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(place.name, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(place.address, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF647782))),
          ])),
        ]),
        const Spacer(),
        Text('${formatDistance(DemoData.center, place.point)} da referência · '
          '$nearby barreira(s) próxima(s)', style: const TextStyle(fontSize: 11,
            color: Color(0xFF647782))),
        const Divider(height: 17),
        const Row(children: [Expanded(child: Text('Abrir ficha de acessibilidade',
          style: TextStyle(fontWeight: FontWeight.w800,
            color: AppColors.sea, fontSize: 12))),
          Icon(Icons.chevron_right, color: AppColors.sea, size: 19)]),
      ]),
    ),
  ));
}
