import 'dart:convert';
import 'dart:typed_data';

import 'package:latlong2/latlong.dart';

enum IncidentStatus { newReport, confirmed, resolved }
enum ModerationStatus { pending, approved, rejected }

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.address,
    required this.point,
    required this.createdAt,
    required this.affectedProfiles,
    this.placeId,
    this.photoDescription,
    this.photoBytes,
    this.votes = const {},
    this.moderation = ModerationStatus.approved,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String address;
  final LatLng point;
  final DateTime createdAt;
  final List<String> affectedProfiles;
  final String? placeId;
  final String? photoDescription;
  final Uint8List? photoBytes;
  // Demonstração: chave = nome do usuário local; valor = 'exists' ou 'resolved'.
  // Produção: o back-end deve validar identidade, unicidade e moderação dos votos.
  final Map<String, String> votes;
  final ModerationStatus moderation;
  bool get isPublic => moderation == ModerationStatus.approved;

  int get existsVotes => votes.values.where((v) => v == 'exists').length;
  int get resolvedVotes => votes.values.where((v) => v == 'resolved').length;

  IncidentStatus get status {
    if (resolvedVotes >= 2) return IncidentStatus.resolved;
    if (existsVotes >= 2) return IncidentStatus.confirmed;
    return IncidentStatus.newReport;
  }

  Incident withVote(String voter, String vote) {
    final updated = Map<String, String>.from(votes);
    // Um novo relato 'ainda existe' reabre o problema anteriormente resolvido.
    if (status == IncidentStatus.resolved && vote == 'exists') updated.clear();
    updated[voter] = vote;
    return copyWith(votes: updated);
  }

  Incident copyWith({Map<String, String>? votes, ModerationStatus? moderation}) => Incident(
        id: id,
        title: title,
        description: description,
        category: category,
        address: address,
        point: point,
        createdAt: createdAt,
        affectedProfiles: affectedProfiles,
        placeId: placeId,
        photoDescription: photoDescription,
        photoBytes: photoBytes,
        votes: votes ?? this.votes,
        moderation: moderation ?? this.moderation,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'address': address,
        'lat': point.latitude,
        'lon': point.longitude,
        'createdAt': createdAt.toIso8601String(),
        'affectedProfiles': affectedProfiles,
        'placeId': placeId,
        'photoDescription': photoDescription,
        // Somente para DEMO. SharedPreferences não é armazenamento de imagens em produção.
        'photoBase64': photoBytes == null ? null : base64Encode(photoBytes!),
        'votes': votes,
        'moderation': moderation.name,
      };

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        address: json['address'] as String,
        point: LatLng(
          (json['lat'] as num).toDouble(),
          (json['lon'] as num).toDouble(),
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        affectedProfiles: List<String>.from(json['affectedProfiles'] as List),
        placeId: json['placeId'] as String?,
        photoDescription: json['photoDescription'] as String?,
        photoBytes: json['photoBase64'] == null
            ? null
            : base64Decode(json['photoBase64'] as String),
        votes: Map<String, String>.from(json['votes'] as Map),
        moderation: ModerationStatus.values.firstWhere(
          (value) => value.name == json['moderation'],
          orElse: () => ModerationStatus.approved),
      );
}
