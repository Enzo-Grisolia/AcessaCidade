import 'package:latlong2/latlong.dart';

class PublicPlace {
  const PublicPlace({
    required this.id,
    required this.name,
    required this.kind,
    required this.address,
    required this.point,
    required this.checklist,
  });

  final String id;
  final String name;
  final String kind;
  final String address;
  final LatLng point;
  // true = atende, false = não atende, null = desconhecido.
  final Map<String, bool?> checklist;
}
