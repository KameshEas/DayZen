import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/journal/models/journal_entry.dart';

class JournalRepository {
  static const _key = 'dz_journal_entries';

  static Future<List<JournalEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }
}
