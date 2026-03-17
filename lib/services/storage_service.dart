import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/water_entry.dart';

class StorageService {
  static const String _dailyGoalKey = 'daily_goal';
  static const String _waterIntakePrefix = 'water_intake_';
  static const String _entriesPrefix = 'entries_';

  // Get today's date key in format YYYY-MM-DD
  String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Save daily goal
  Future<void> saveDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyGoalKey, goal);
  }

  // Get daily goal (default 2000ml)
  Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyGoalKey) ?? 2000;
  }

  // Save water intake for a specific date
  Future<void> saveWaterIntake(int amount, String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_waterIntakePrefix$date', amount);
  }

  // Get water intake for a specific date
  Future<int> getWaterIntake(String date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_waterIntakePrefix$date') ?? 0;
  }

  // Get today's water intake
  Future<int> getTodayWaterIntake() async {
    return getWaterIntake(_getTodayKey());
  }

  // Save entries for a specific date
  Future<void> saveEntries(List<WaterEntry> entries, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString('$_entriesPrefix$date', jsonString);
  }

  // Get entries for a specific date
  Future<List<WaterEntry>> getEntries(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_entriesPrefix$date');

    if (jsonString == null) {
      return [];
    }

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => WaterEntry.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Get today's entries
  Future<List<WaterEntry>> getTodayEntries() async {
    return getEntries(_getTodayKey());
  }

  // Clean up old entries (keep last 30 days)
  Future<void> cleanupOldEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_entriesPrefix) || key.startsWith(_waterIntakePrefix)) {
        final dateString = key.replaceFirst(_entriesPrefix, '').replaceFirst(_waterIntakePrefix, '');
        try {
          final date = DateFormat('yyyy-MM-dd').parse(dateString);
          if (date.isBefore(thirtyDaysAgo)) {
            await prefs.remove(key);
          }
        } catch (e) {
          // Skip invalid date keys
        }
      }
    }
  }
}
