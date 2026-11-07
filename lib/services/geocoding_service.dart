import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/geocoded_address.dart';

/// API REST real: Nominatim/OpenStreetMap (somente consulta após ação explícita).
/// O serviço público limita chamadas a no máximo uma por segundo e proíbe autocomplete.
class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<GeocodedAddress> reverse(LatLng point) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': '${point.latitude}',
      'lon': '${point.longitude}',
      'zoom': '18',
      'addressdetails': '1',
      'accept-language': 'pt-BR',
    });

    try {
      final response = await _client.get(uri, headers: {
        'Accept': 'application/json',
        // Na Web, o próprio navegador fornece Referer/User-Agent.
        if (!kIsWeb) 'User-Agent': 'AcessaCidadeGS/0.1 (+https://github.com/Enzo-Grisolia)',
      }).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('Serviço de endereços indisponível (HTTP ${response.statusCode}).');
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Formato de endereço inesperado.');
      }
      return GeocodedAddress.fromJson(json);
    } catch (error) {
      throw Exception('Não foi possível consultar o endereço: $error');
    }
  }

  void dispose() => _client.close();
}
