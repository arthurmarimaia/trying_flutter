import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available profile avatar icons.
const List<String> profileAvatars = [
  '🐶', '🦎', '🟢', '🐱', '🐰', '🐻', '🦊', '🐼', '🐸', '🐯',
  '🦁', '🐲', '🐵', '🐧', '🦋',
];

class AuthService extends ChangeNotifier {
  static const _profilesKey = 'auth_profiles';
  static const _activeKey   = 'auth_active_user';

  bool _initialized = false;
  String? _activeUsername;

  bool get initialized      => _initialized;
  bool get isLoggedIn       => _activeUsername != null;
  String? get activeUsername => _activeUsername;

  /// SharedPreferences prefix used by StorageService / PetController.
  String get storagePrefix =>
      _activeUsername == null ? '' : 'u_$_activeUsername';

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_activeKey);
    if (saved != null && saved.isNotEmpty) {
      final profiles = await _loadProfiles(prefs);
      if (profiles.any((p) => p['username'] == saved)) {
        _activeUsername = saved;
      }
    }
    _initialized = true;
    notifyListeners();
  }

  // ── Profile operations ────────────────────────────────────────────────────

  /// Creates a new profile. Returns error message or `null` on success.
  Future<String?> createProfile(String name, String avatar) async {
    name = name.trim().toLowerCase();
    if (name.length < 3) return 'Nome deve ter ao menos 3 caracteres';
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(name)) {
      return 'Use apenas letras, números ou _';
    }

    final prefs = await SharedPreferences.getInstance();
    final profiles = await _loadProfiles(prefs);

    if (profiles.any((p) => p['username'] == name)) {
      return 'Este nome já está em uso';
    }

    profiles.add({'username': name, 'avatar': avatar});
    await prefs.setString(_profilesKey, jsonEncode(profiles));

    _activeUsername = name;
    await prefs.setString(_activeKey, name);
    notifyListeners();
    return null;
  }

  /// Selects an existing profile (no password needed).
  Future<void> selectProfile(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _activeUsername = username;
    await prefs.setString(_activeKey, username);
    notifyListeners();
  }

  /// Deletes a profile and all its data keys.
  Future<void> deleteProfile(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await _loadProfiles(prefs);
    profiles.removeWhere((p) => p['username'] == username);
    await prefs.setString(_profilesKey, jsonEncode(profiles));

    // Remove all data keys for this profile
    final prefix = 'u_$username';
    final allKeys = prefs.getKeys().where((k) => k.startsWith(prefix));
    for (final key in allKeys) {
      await prefs.remove(key);
    }

    // If the deleted profile was active, log out
    if (_activeUsername == username) {
      _activeUsername = null;
      await prefs.remove(_activeKey);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _activeUsername = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeKey);
    notifyListeners();
  }

  /// Returns list of profiles with 'username' and 'avatar' keys.
  Future<List<Map<String, dynamic>>> listProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadProfiles(prefs);
  }

  Future<List<String>> listUsernames() async {
    final profiles = await listProfiles();
    return profiles.map((p) => p['username'] as String).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _loadProfiles(SharedPreferences prefs) async {
    final raw = prefs.getString(_profilesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }
}
