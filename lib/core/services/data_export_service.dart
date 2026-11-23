import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../api/api_client.dart';
import '../data/checkin_repository.dart';
import '../data/day_close_repository.dart';
import '../data/journal_repository.dart';
import '../data/task_repository.dart';
import 'task_service.dart';

/// "Export my data" (plan M-2.8; DPDP right of access).
///
/// - Signed in: the server's `GET /users/me/export` (A-2.2).
/// - Signed out: the same shape built from this phone's database.
///
/// Either way, data that only ever lives on this phone (energy check-ins,
/// closed days) is added under `local_only`, since the server never has it.
/// The file is handed to the system share sheet; nothing is uploaded
/// anywhere by this service apart from the authenticated GET above.
class DataExportService {
  DataExportService({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  static const format = 'dayzen-export/1';

  /// The export as a JSON-ready map.
  Future<Map<String, dynamic>> build({required bool signedIn, DateTime? now}) async {
    final at = now ?? DateTime.now();
    final Map<String, dynamic> base =
        signedIn ? await _api.get('/users/me/export') : await localExport(now: at);
    return {...base, 'local_only': await localOnly()};
  }

  /// Signed-out export: the server's shape, from local tables.
  Future<Map<String, dynamic>> localExport({DateTime? now}) async {
    final tasks = await TaskRepository.loadAll();
    final journal = await JournalRepository.loadAll();
    return {
      'format': format,
      'exported_at': (now ?? DateTime.now()).toUtc().toIso8601String(),
      'source': 'device',
      'profile': null,
      'settings': null,
      'tasks': [
        for (final t in tasks) {...TaskService.taskSyncJson(t), 'deleted': false},
      ],
      'journal': [
        for (final e in journal)
          {
            'id': e.id,
            'title': e.title,
            'body': e.body,
            'mood': e.mood.name,
            'timestamp_ms': e.timestamp.millisecondsSinceEpoch,
            'entry_timestamp': e.timestamp.toIso8601String(),
            'accent_color_value': e.accentColor?.toARGB32(),
            'deleted': false,
          },
      ],
    };
  }

  /// Check-ins and closed days: on this phone only.
  Future<Map<String, dynamic>> localOnly() async {
    final checkins = await const CheckinRepository().since(DateTime(2000));
    final closes =
        await const DayCloseRepository().between(DateTime(2000), DateTime(2100));
    return {
      'checkins': [
        for (final c in checkins)
          {'at': c.at.toIso8601String(), 'energy': c.energy, 'mood': c.mood},
      ],
      'day_closes': [
        for (final d in closes)
          {
            'date': d.date.toIso8601String().substring(0, 10),
            'closed_at': d.closedAt.toIso8601String(),
            'done': d.done,
            'carried': d.carried,
            'released': d.released,
            'journal_entry_id': d.journalEntryId,
          },
      ],
    };
  }

  /// Writes the export to a temporary file and opens the share sheet.
  Future<void> exportAndShare({required bool signedIn}) async {
    final data = await build(signedIn: signedIn);
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '');
    final file = File('${dir.path}${Platform.pathSeparator}dayzen-export-$stamp.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      subject: 'My DayZen data',
    ));
  }
}
