import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';
import '../core/demo_data.dart';
import '../models/incident.dart';
import '../models/geocoded_address.dart';
import '../services/app_state.dart';
import '../services/geocoding_service.dart';
import '../widgets/profile_sheet.dart';
import '../widgets/ui_parts.dart';
import 'incident_detail_screen.dart';

enum ApiPhase { initial, loading, success, error }

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.state});
  final AppState state;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _altDescription = TextEditingController();
  final _geocoder = GeocodingService();

  String _category = DemoData.categories.first;
  String? _placeId;
  Set<String> _profiles = {'Cadeirante'};
  LatLng _point = DemoData.center;
  Uint8List? _imageBytes;
  ApiPhase _apiPhase = ApiPhase.initial;
  String? _apiError;
  bool _saving = false;
  DateTime? _lastApiCall;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _address.dispose();
    _altDescription.dispose();
    _geocoder.dispose();
    super.dispose();
  }

  Future<void> _findAddress() async {
    // Evita repetição acidental: limite público Nominatim = no máximo 1 req/s.
    final now = DateTime.now();
    if (_apiPhase == ApiPhase.loading) return;
    if (_lastApiCall != null &&
        now.difference(_lastApiCall!).inMilliseconds < 1100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Espere um instante antes de consultar novamente.')));
      return;
    }
    _lastApiCall = now;
    setState(() {
      _apiPhase = ApiPhase.loading;
      _apiError = null;
    });
    try {
      final GeocodedAddress result = await _geocoder.reverse(_point);
      if (!mounted) return;
      _address.text = result.displayName;
      setState(() => _apiPhase = ApiPhase.success);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _apiError = error.toString();
        _apiPhase = ApiPhase.error;
      });
    }
  }

  Future<void> _choosePhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 700, imageQuality: 55,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      // Não guarde fotos grandes em SharedPreferences; limite conservador para demo.
      if (bytes.length > 400000) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
          Text('Imagem muito grande para o protótipo. Escolha outra foto.')));
        return;
      }
      setState(() => _imageBytes = bytes);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir a galeria: $error')));
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_profiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
        Text('Selecione pelo menos um perfil afetado.')));
      return;
    }
    if (!widget.state.signedIn) {
      await showProfileSheet(context, widget.state);
      if (!widget.state.signedIn) return;
    }
    setState(() => _saving = true);
    final incident = Incident(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category,
      address: _address.text.trim(),
      point: _point,
      createdAt: DateTime.now(),
      affectedProfiles: _profiles.toList(),
      placeId: _placeId,
      photoDescription: _imageBytes == null ? null : _altDescription.text.trim(),
      photoBytes: _imageBytes,
      moderation: ModerationStatus.pending,
    );
    try {
      await widget.state.addIncident(incident);
      if (!mounted) return;
      setState(() => _saving = false);
      _form.currentState!.reset();
      _title.clear();
      _description.clear();
      _address.clear();
      _altDescription.clear();
      setState(() {
        _category = DemoData.categories.first;
        _placeId = null;
        _profiles = {'Cadeirante'};
        _imageBytes = null;
        _point = DemoData.center;
        _apiPhase = ApiPhase.initial;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
        Text('Relato enviado para validação. Ele aparecerá no mapa após aprovação.')));
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) =>
        IncidentDetailScreen(state: widget.state, incidentId: incident.id)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
          Text('Não foi possível salvar o relato: $error')));
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) =>
    Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 950),
    child: ListView(
    padding: EdgeInsets.fromLTRB(c.maxWidth >= 790 ? 32 : 16,
      27, c.maxWidth >= 790 ? 32 : 16, 32),
    children: [
      const PageHeading(
        eyebrow: 'Colabore com o bairro',
        title: 'Novo relato',
        subtitle: 'Encontrou uma barreira? Ajude outras pessoas registrando o que aconteceu.'),
      const SizedBox(height: 16),
      const _ModerationNotice(),
      const SizedBox(height: 14),
      Form(key: _form, child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. O que você encontrou?', style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 10),
          TextFormField(
            controller: _title, maxLength: 65,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Título do relato *',
              hintText: 'Ex.: Rampa com degrau muito alto'),
            validator: (value) => (value?.trim().length ?? 0) < 8
                ? 'Digite pelo menos 8 caracteres.' : null,
          ),
          const SizedBox(height: 9),
          DropdownButtonFormField<String>(
            key: ValueKey('category_$_category'),
            initialValue: _category, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Categoria da barreira *'),
            items: DemoData.categories.map((category) => DropdownMenuItem(
              value: category, child: Text(category))).toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _description, maxLines: 3, maxLength: 280,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Descreva a barreira *',
              hintText: 'O que, onde e como ela dificulta o acesso?'),
            validator: (value) => (value?.trim().length ?? 0) < 15
                ? 'Descreva o problema em pelo menos 15 caracteres.' : null,
          ),
          const SizedBox(height: 12),
          const Text('Perfis afetados *',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Wrap(spacing: 7, runSpacing: 2, children: [
            for (final profile in DemoData.profiles)
              FilterChip(
                label: Text(profile), selected: _profiles.contains(profile),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _profiles.add(profile);
                  } else {
                    _profiles.remove(profile);
                  }
                }),
              ),
          ]),
          const SizedBox(height: 20),
          const Text('2. Localização da barreira', style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 7),
          const Text('Toque em um ponto do mapa para fixar a ocorrência. '
              'As ruas são reais; os relatos de exemplo, não.',
              style: TextStyle(fontSize: 12, color: Color(0xFF647782))),
          const SizedBox(height: 11),
          ClipRRect(borderRadius: BorderRadius.circular(15),
            child: SizedBox(height: 220,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _point, initialZoom: 16,
                  onTap: (_, tappedPoint) => setState(() {
                    _point = tappedPoint;
                    _address.clear();
                    _apiError = null;
                    _apiPhase = ApiPhase.initial;
                  }),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'br.com.acessacidade.gs',
                  ),
                  MarkerLayer(markers: [
                    Marker(point: _point, width: 49, height: 49,
                      child: const Icon(Icons.location_on_rounded,
                        size: 46, color: AppColors.red)),
                  ]),
                  const SimpleAttributionWidget(
                      source: Text('OpenStreetMap contributors')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Ponto: ${_point.latitude.toStringAsFixed(5)}, '
              '${_point.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF647782))),
          const SizedBox(height: 11),
          SizedBox(width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _apiPhase == ApiPhase.loading ? null : _findAddress,
              icon: _apiPhase == ApiPhase.loading
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.travel_explore_outlined, size: 19),
              label: Text(_apiPhase == ApiPhase.loading
                  ? 'Consultando endereço...' :
                  _apiPhase == ApiPhase.error ? 'Tentar consulta novamente' :
                  'Consultar endereço (API REST)'),
            ),
          ),
          if (_apiPhase == ApiPhase.success)
            const Padding(padding: EdgeInsets.only(top: 6), child: Text(
              'Endereço retornado pela API. Confira e ajuste se necessário.',
              style: TextStyle(color: AppColors.sea, fontSize: 12))),
          if (_apiPhase == ApiPhase.error) ...[
            const SizedBox(height: 7),
            Text(_apiError ?? 'Erro inesperado.',
              style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ],
          const SizedBox(height: 11),
          TextFormField(
            controller: _address, maxLines: 2, maxLength: 240,
            decoration: const InputDecoration(
              labelText: 'Endereço / referência *',
              hintText: 'Informe manualmente se a API falhar',
            ),
            validator: (value) => (value?.trim().length ?? 0) < 6
                ? 'Informe um endereço ou referência legível.' : null,
          ),
          const SizedBox(height: 11),
          DropdownButtonFormField<String?>(
            key: ValueKey('place_${_placeId ?? 'none'}'),
            initialValue: _placeId,
            isExpanded: true,
            decoration: const InputDecoration(
                labelText: 'Vincular a serviço público (opcional)'),
            items: [
              const DropdownMenuItem<String?>(value: null,
                  child: Text('Sem vínculo')),
              for (final place in DemoData.places)
                DropdownMenuItem<String?>(value: place.id,
                  child: Text(place.name, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (value) => setState(() => _placeId = value),
          ),
          const SizedBox(height: 22),
          const Text('3. Evidência (opcional)', style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 8),
          const Text('Foto opcional. Se anexar, descreva o que ela mostra '
              'para permitir a leitura por tecnologia assistiva.',
            style: TextStyle(fontSize: 12, color: Color(0xFF647782))),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_imageBytes == null ? 'Selecionar foto' : 'Trocar foto'),
            onPressed: _choosePhoto,
          ),
          if (_imageBytes != null) ...[
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.memory(_imageBytes!, height: 145,
                  width: double.infinity, fit: BoxFit.cover)),
            TextButton.icon(
              onPressed: () => setState(() {
                _imageBytes = null;
                _altDescription.clear();
              }),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remover foto'),
            ),
            TextFormField(
              controller: _altDescription,
              maxLines: 2, maxLength: 210,
              decoration: const InputDecoration(
                labelText: 'Descrição textual da foto *',
                hintText: 'Ex.: rampa com degrau ao lado de uma parada'),
              validator: (text) => _imageBytes != null &&
                    (text?.trim().length ?? 0) < 15
                  ? 'A foto exige uma descrição acessível de 15 caracteres.'
                  : null,
            ),
          ],
          const SizedBox(height: 23),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2,
                  color: Colors.white)) : const Icon(Icons.send_outlined),
            label: Text(_saving ? 'Salvando...' : 'Enviar relato para validação'),
          )),
          const SizedBox(height: 12),
          const Text('Protótipo local: relatos e fotos pequenas são gravados '
            'neste dispositivo para avaliação. Em produção, usar API autenticada, '
            'banco de dados, armazenamento de imagens e moderação.',
            style: TextStyle(fontSize: 11, color: Color(0xFF647782))),
        ],
      )),
    ]))));
}

class _ModerationNotice extends StatelessWidget {
  const _ModerationNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: AppColors.amberLight,
      border: Border.all(color: const Color(0xFFF4D9A8)),
      borderRadius: BorderRadius.circular(12)),
    child: const Row(children: [
      Icon(Icons.info_outline, color: AppColors.amber, size: 20),
      SizedBox(width: 9),
      Expanded(child: Text('Este relato entra na fila de moderação. '
        'Somente após aprovação ele aparece no mapa público. Validação simulada local.',
        style: TextStyle(fontSize: 12, color: AppColors.ink))),
    ]),
  );
}
