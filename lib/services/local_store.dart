import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/incident.dart';

class LocalStore {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<bool> get skipOnboarding async =>
      await _prefs.getBool('ac_skip_onboarding') ?? false;

  Future<void> setSkipOnboarding(bool value) =>
      _prefs.setBool('ac_skip_onboarding', value);

  Future<String?> get displayName => _prefs.getString('ac_user_name');
  Future<void> setDisplayName(String? name) async {
    if (name == null) {
      await _prefs.remove('ac_user_name');
    } else {
      await _prefs.setString('ac_user_name', name);
    }
  }

  Future<List<String>> get profile async =>
      await _prefs.getStringList('ac_profile') ?? <String>[];

  Future<void> setProfile(List<String> profiles) =>
      _prefs.setStringList('ac_profile', profiles);

  Future<List<Incident>?> loadIncidents() async {
    final raw = await _prefs.getString('ac_incidents_v1');
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => Incident.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      // Preserva o app se uma versão anterior tiver deixado JSON inválido.
      return null;
    }
  }

  Future<void> saveIncidents(List<Incident> incidents) async =>
      _prefs.setString('ac_incidents_v1',
          jsonEncode(incidents.map((incident) => incident.toJson()).toList()));

  Future<void> resetIncidents() => _prefs.remove('ac_incidents_v1');
}
