import 'package:flutter/foundation.dart';

import '../core/demo_data.dart';
import '../models/incident.dart';
import 'local_store.dart';

class AppState extends ChangeNotifier {
  final LocalStore _store = LocalStore();

  List<Incident> incidents = DemoData.seedIncidents();
  String? displayName;
  List<String> profiles = [];
  bool skipOnboarding = false;

  List<Incident> get publicIncidents =>
      incidents.where((incident) => incident.isPublic).toList();

  List<Incident> get pendingIncidents =>
      incidents.where((incident) =>
          incident.moderation == ModerationStatus.pending).toList();

  bool get signedIn => displayName != null && displayName!.trim().isNotEmpty;

  Future<void> initialize() async {
    skipOnboarding = await _store.skipOnboarding;
    displayName = await _store.displayName;
    profiles = await _store.profile;
    incidents = await _store.loadIncidents() ?? DemoData.seedIncidents();
    notifyListeners();
  }

  Future<void> completeOnboarding(bool dontShowAgain) async {
    skipOnboarding = dontShowAgain;
    await _store.setSkipOnboarding(dontShowAgain);
    notifyListeners();
  }

  Future<void> saveProfile(String? name, List<String> selectedProfiles) async {
    displayName = (name?.trim().isEmpty ?? true) ? null : name!.trim();
    profiles = [...selectedProfiles];
    await _store.setDisplayName(displayName);
    await _store.setProfile(profiles);
    notifyListeners();
  }

  Future<void> addIncident(Incident incident) async {
    incidents = [incident, ...incidents];
    await _store.saveIncidents(incidents);
    notifyListeners();
  }

  Future<void> moderateIncident(String incidentId, bool approve) async {
    final index = incidents.indexWhere((i) => i.id == incidentId);
    if (index < 0) return;
    final updated = [...incidents];
    updated[index] = updated[index].copyWith(
      moderation: approve ? ModerationStatus.approved : ModerationStatus.rejected);
    incidents = updated;
    await _store.saveIncidents(incidents);
    notifyListeners();
  }

  Future<bool> vote(String incidentId, String vote) async {
    if (!signedIn) return false;
    final index = incidents.indexWhere((i) => i.id == incidentId);
    if (index < 0 || !incidents[index].isPublic) return false;
    final updated = [...incidents];
    updated[index] = updated[index].withVote(displayName!, vote);
    incidents = updated;
    await _store.saveIncidents(incidents);
    notifyListeners();
    return true;
  }

  Future<void> restoreDemoIncidents() async {
    incidents = DemoData.seedIncidents();
    await _store.resetIncidents();
    notifyListeners();
  }
}
