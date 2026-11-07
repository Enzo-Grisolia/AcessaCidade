import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';
import '../core/demo_data.dart';
import '../models/incident.dart';
import '../models/public_place.dart';
import '../services/app_state.dart';
import '../widgets/ui_parts.dart';
import 'incident_detail_screen.dart';
import 'place_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.state});
  final AppState state;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _asList = false;
  String _profile = 'Todos os perfis';
  String _category = 'Todas as barreiras';
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.state.profiles.isNotEmpty) {
      _profile = widget.state.profiles.first;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Incident> _filtered(List<Incident> incidents) {
    final result = incidents
        .where(
          (incident) =>
              (_profile == 'Todos os perfis' ||
                  incident.affectedProfiles.contains(_profile)) &&
              (_category == 'Todas as barreiras' ||
                  incident.category == _category),
        )
        .toList();
    result.sort(
      (a, b) => const Distance()(
        DemoData.center,
        a.point,
      ).compareTo(const Distance()(DemoData.center, b.point)),
    );
    return result;
  }

  void _openIncident(Incident incident) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) =>
          IncidentDetailScreen(state: widget.state, incidentId: incident.id),
    ),
  );

  void _openPlace(PublicPlace place) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => PlaceDetailScreen(state: widget.state, place: place),
    ),
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.state,
    builder: (context, _) {
      final incidents = _filtered(widget.state.publicIncidents);
      return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 920;
          // Desktop has a scrollable heading/filters and a two-column map area;
          // mobile keeps a single-column layout and its equivalent accessible list.
          final heading = Padding(
            padding: EdgeInsets.fromLTRB(
              wide ? 30 : 16,
              19,
              wide ? 30 : 16,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DemoNotice(compact: true),
                const SizedBox(height: 23),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore o bairro',
                            style: TextStyle(
                              fontSize: wide ? 28 : 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            DemoData.district,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF647782),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _asList = !_asList),
                      icon: Icon(
                        _asList ? Icons.map_outlined : Icons.list_alt_outlined,
                        size: 18,
                      ),
                      label: Text(_asList ? 'Ver mapa' : 'Ver lista'),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _selector(
                        label: 'Perfil',
                        value: _profile,
                        values: ['Todos os perfis', ...DemoData.profiles],
                        onChanged: (value) => setState(() => _profile = value!),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: _selector(
                        label: 'Barreira',
                        value: _category,
                        values: ['Todas as barreiras', ...DemoData.categories],
                        onChanged: (value) =>
                            setState(() => _category = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${incidents.length} relatos encontrados  •  ${DemoData.places.length} locais de referência',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF647782),
                  ),
                ),
              ],
            ),
          );
          return Column(
            children: [
              heading,
              Expanded(
                child: _asList
                    ? _accessibleList(incidents)
                    : wide
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(17),
                                child: _map(incidents),
                              ),
                            ),
                            const SizedBox(width: 17),
                            SizedBox(
                              width: 314,
                              child: _nearbyPanel(incidents),
                            ),
                          ],
                        ),
                      )
                    : _map(incidents),
              ),
            ],
          );
        },
      );
    },
  );

  Widget _nearbyPanel(List<Incident> incidents) {
    final ordered = [...incidents]
      ..sort((a, b) => _priorityForStatus(a).compareTo(_priorityForStatus(b)));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 18, 17, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Barreiras na região',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${incidents.length} relatos • clique para abrir a ficha',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF657782),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outline),
          Expanded(
            child: ordered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhum relato encontrado com esses filtros.',
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: ordered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final incident = ordered[index];
                      return IncidentCard(
                        incident: incident,
                        onTap: () => _openIncident(incident),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _asList = true),
              icon: const Icon(Icons.format_list_bulleted),
              label: const Text('Visualizar lista completa'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _priorityForStatus(Incident incident) => switch (incident.status) {
    IncidentStatus.confirmed => 0,
    IncidentStatus.newReport => 1,
    IncidentStatus.resolved => 2,
  };

  Widget _selector({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      ),
      items: [
        for (final item in values)
          DropdownMenuItem(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _map(List<Incident> incidents) => Stack(
    children: [
      FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: DemoData.center,
          initialZoom: 15.1,
          minZoom: 11,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'br.com.acessacidade.gs',
          ),
          MarkerLayer(
            markers: [
              for (final place in DemoData.places)
                Marker(
                  point: place.point,
                  width: 36,
                  height: 36,
                  child: Semantics(
                    button: true,
                    label:
                        'Abrir ficha de ${place.kind}: ${place.name}, ${place.address}',
                    child: Tooltip(
                      message: place.name,
                      child: InkWell(
                        onTap: () => _openPlace(place),
                        child: _pin(
                          Icons.location_city_outlined,
                          AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              for (final incident in incidents)
                Marker(
                  point: incident.point,
                  width: 38,
                  height: 38,
                  child: Semantics(
                    button: true,
                    label:
                        'Abrir relato: ${incident.title}, ${incident.address}',
                    child: Tooltip(
                      message: incident.title,
                      child: InkWell(
                        onTap: () => _openIncident(incident),
                        child: _pin(
                          Icons.report_problem_outlined,
                          incident.status == IncidentStatus.confirmed
                              ? AppColors.red
                              : incident.status == IncidentStatus.resolved
                              ? AppColors.sea
                              : AppColors.amber,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors'),
          ),
        ],
      ),
      Positioned(
        top: 12,
        right: 14,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          elevation: 1,
          child: IconButton(
            tooltip: 'Centralizar mapa na região de demonstração',
            icon: const Icon(Icons.my_location, color: AppColors.sea),
            onPressed: () => _mapController.move(DemoData.center, 15.1),
          ),
        ),
      ),
      Positioned(
        left: 12,
        right: 12,
        bottom: 34,
        child: IgnorePointer(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Wrap(
              spacing: 15,
              runSpacing: 7,
              children: [
                _Legend(color: AppColors.ink, text: 'Serviço público'),
                _Legend(color: AppColors.red, text: 'Barreira confirmada'),
                _Legend(color: AppColors.amber, text: 'Barreira nova'),
                _Legend(color: AppColors.sea, text: 'Resolvida'),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _pin(IconData icon, Color color) => Center(
    child: Container(
      width: 33,
      height: 33,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 7),
        ],
      ),
      child: Icon(icon, size: 17, color: Colors.white),
    ),
  );

  Widget _accessibleList(List<Incident> incidents) {
    final places = [...DemoData.places]
      ..sort(
        (a, b) => const Distance()(
          DemoData.center,
          a.point,
        ).compareTo(const Distance()(DemoData.center, b.point)),
      );
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 5, 14, 24),
      children: [
        const Text(
          'Visualização equivalente ao mapa',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ordenado pela distância ao ponto de referência, não pela sua posição GPS.',
          style: TextStyle(fontSize: 12, color: Color(0xFF647782)),
        ),
        const SizedBox(height: 16),
        Text(
          'Serviços públicos (${places.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        for (final place in places) ...[
          PlaceCard(
            place: place,
            onTap: () => _openPlace(place),
            activeIssues: widget.state.publicIncidents
                .where(
                  (incident) =>
                      incident.status != IncidentStatus.resolved &&
                      const Distance()(incident.point, place.point) <= 150,
                )
                .length,
          ),
          const SizedBox(height: 9),
        ],
        const SizedBox(height: 14),
        Text(
          'Relatos filtrados (${incidents.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        if (incidents.isEmpty)
          const Text('Nenhum relato corresponde aos filtros selecionados.'),
        for (final incident in incidents) ...[
          IncidentCard(
            incident: incident,
            onTap: () => _openIncident(incident),
          ),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
    ],
  );
}
