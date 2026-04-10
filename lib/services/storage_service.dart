import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class StorageService {
  static const String _petKey = 'pet_data';
  static const String _goalsKey = 'daily_goals';
  static const String _actionCountsKey = 'daily_action_counts';
  static const String _actionTimesKey = 'last_action_times';
  static const String _storeStateKey = 'store_state';
  static const String _eventStateKey = 'event_state';

  // Salvar pet
  static Future<void> savePet(Pet pet) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(pet.toMap());
    await prefs.setString(_petKey, jsonString);
  }

  // Carregar pet
  static Future<Pet?> loadPet() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_petKey);

    if (jsonString == null) return null;

    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return Pet.fromMap(map);
  }

  static Future<void> saveDailyGoals(List<Map<String, dynamic>> goals, DateTime lastReset) async {
    final prefs = await SharedPreferences.getInstance();
    final state = {
      'goals': jsonEncode(goals),
      'lastReset': lastReset.toIso8601String(),
    };
    await prefs.setString(_goalsKey, jsonEncode(state));
  }

  static Future<Map<String, dynamic>?> loadDailyGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_goalsKey);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<void> saveActionCounts(Map<String, int> counts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(counts);
    await prefs.setString(_actionCountsKey, jsonString);
  }

  static Future<Map<String, int>> loadActionCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_actionCountsKey);
    if (jsonString == null) return {};
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, value as int));
  }

  static Future<void> saveActionTimes(Map<String, DateTime> times) async {
    final prefs = await SharedPreferences.getInstance();
    final map = times.map((key, value) => MapEntry(key, value.toIso8601String()));
    final jsonString = jsonEncode(map);
    await prefs.setString(_actionTimesKey, jsonString);
  }

  static Future<Map<String, DateTime>> loadActionTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_actionTimesKey);
    if (jsonString == null) return {};
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, DateTime.parse(value)));
  }

  static Future<void> saveStoreState(Map<String, bool> ownedItems, String selectedAccessory) async {
    final prefs = await SharedPreferences.getInstance();
    final state = {
      'ownedItems': jsonEncode(ownedItems),
      'selectedAccessory': selectedAccessory,
    };
    await prefs.setString(_storeStateKey, jsonEncode(state));
  }

  static Future<Map<String, dynamic>> loadStoreState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storeStateKey);
    if (jsonString == null) return {};
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<void> saveEventState(Map<String, dynamic> eventState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_eventStateKey, jsonEncode(eventState));
  }

  static Future<Map<String, dynamic>> loadEventState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_eventStateKey);
    if (jsonString == null) return {};
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Limpar dados (útil para testes)
  static Future<void> clearPet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_petKey);
  }
}