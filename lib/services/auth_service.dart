import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const _profilesKey = 'auth_profiles';
  static const _activeKey   = 'auth_active_user';

  bool _initialized = false;
  String? _activeUsername;

  bool get initialized    => _initialized;
  bool get isLoggedIn     => _activeUsername != null;
  String? get activeUsername => _activeUsername;

  /// SharedPreferences prefix used by StorageService / PetController.
  String get storagePrefix =>
      _activeUsername == null ? '' : 'u_$_activeUsername';

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_activeKey);
    if (saved != null && saved.isNotEmpty) {
      // Validate the saved user still exists
      final profiles = await _loadProfiles(prefs);
      if (profiles.any((p) => p['username'] == saved)) {
        _activeUsername = saved;
      }
    }
    _initialized = true;
    notifyListeners();
  }

  // ── Auth operations ──────────────────────────────────────────────────────

  /// Returns an error message, or `null` on success.
  Future<String?> register(String username, String password) async {
    username = username.trim().toLowerCase();
    if (username.length < 3) return 'Nome deve ter ao menos 3 caracteres';
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      return 'Use apenas letras, números ou _';
    }
    if (password.length < 4) return 'Senha deve ter ao menos 4 caracteres';

    final prefs = await SharedPreferences.getInstance();
    final profiles = await _loadProfiles(prefs);

    if (profiles.any((p) => p['username'] == username)) {
      return 'Nome de usuário já está em uso';
    }

    profiles.add({'username': username, 'hash': _hash(username, password)});
    await prefs.setString(_profilesKey, jsonEncode(profiles));

    _activeUsername = username;
    await prefs.setString(_activeKey, username);
    notifyListeners();
    return null;
  }

  /// Returns an error message, or `null` on success.
  Future<String?> login(String username, String password) async {
    username = username.trim().toLowerCase();

    final prefs = await SharedPreferences.getInstance();
    final profiles = await _loadProfiles(prefs);

    final match = profiles.cast<Map<String, dynamic>?>().firstWhere(
      (p) => p!['username'] == username,
      orElse: () => null,
    );
    if (match == null) return 'Usuário não encontrado';
    if (match['hash'] != _hash(username, password)) return 'Senha incorreta';

    _activeUsername = username;
    await prefs.setString(_activeKey, username);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _activeUsername = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeKey);
    notifyListeners();
  }

  Future<List<String>> listUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await _loadProfiles(prefs);
    return profiles.map((p) => p['username'] as String).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _loadProfiles(SharedPreferences prefs) async {
    final raw = prefs.getString(_profilesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  String _hash(String username, String password) {
    final bytes = utf8.encode('$username:$password:tama_local_v1');
    return sha256.convert(bytes).toString();
  }
}
