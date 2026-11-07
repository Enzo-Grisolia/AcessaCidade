class GeocodedAddress {
  const GeocodedAddress({required this.displayName});
  final String displayName;

  factory GeocodedAddress.fromJson(Map<String, dynamic> json) {
    final name = json['display_name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Endereço não encontrado para esse ponto.');
    }
    return GeocodedAddress(displayName: name);
  }
}
