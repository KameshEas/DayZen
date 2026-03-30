import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/models/task_model.dart';

class TaskRepository {
  static const _key = 'dz_tasks';

  static Future<List<DzTask>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => DzTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save(List<DzTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }
}
