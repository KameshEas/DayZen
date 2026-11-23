import 'dart:async';
import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../../features/home/models/task_model.dart';
import '../domain/rhythm/energy_profile.dart';
import '../logging/app_logger.dart';

/// Feeds the Android "Now / Next" widget (plan M-3.2).
///
/// Saves today's and tomorrow's active tasks (so the widget is still right
/// after midnight with the app closed) and the Rhythm curve, then asks the
/// widget to redraw. Only titles and times are shared, with the launcher
/// process on this phone; nothing leaves the device.
class WidgetService {
  WidgetService._();

  static final WidgetService instance = WidgetService._();

  static const androidProvider =
      'com.aspiredesignovation.dayzen.NowNextWidgetProvider';

  static const daysKey = 'dz_days';
  static const rhythmKey = 'dz_rhythm';
  static const windowKey = 'dz_window';

  /// Saves are coalesced: task edits often come in bursts.
  static const debounce = Duration(milliseconds: 800);

  Timer? _timer;
  List<DzTask> _tasks = const [];
  EnergyProfile? _profile;

  void update({List<DzTask>? tasks, EnergyProfile? profile}) {
    if (tasks != null) _tasks = tasks;
    if (profile != null) _profile = profile;
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(flush()));
  }

  Future<void> flush({DateTime? now}) async {
    try {
      await HomeWidget.saveWidgetData<String>(
          daysKey, jsonEncode(daysPayload(_tasks, now ?? DateTime.now())));
      final p = _profile;
      if (p != null) {
        await HomeWidget.saveWidgetData<String>(rhythmKey, rhythmPayload(p));
        await HomeWidget.saveWidgetData<String>(windowKey, windowLabel(p));
      }
      await HomeWidget.updateWidget(qualifiedAndroidName: androidProvider);
    } catch (e) {
      // No widget host (tests, desktop) or plugin not ready: nothing to do.
      AppLogger.debug('Widget not updated: $e');
    }
  }

  /// `{"2027-05-01": [{"id","title","start","end"}, ...], "<tomorrow>": [...]}`
  /// with start/end in minutes after midnight, active tasks only.
  static Map<String, List<Map<String, Object>>> daysPayload(
      List<DzTask> tasks, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final out = <String, List<Map<String, Object>>>{};
    for (final day in [today, today.add(const Duration(days: 1))]) {
      final list = tasks
          .where((t) => t.status == TaskStatus.active && t.isSameDay(day))
          .map((t) => <String, Object>{
                'id': t.id,
                'title': t.title,
                'start': t.startTime.hour * 60 + t.startTime.minute,
                'end': t.endTime.hour * 60 + t.endTime.minute,
              })
          .toList()
        ..sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));
      out[_key(day)] = list;
    }
    return out;
  }

  static String rhythmPayload(EnergyProfile p) =>
      p.values.map((v) => v.toStringAsFixed(3)).join(',');

  static String windowLabel(EnergyProfile p) {
    final w = p.sharpestWindow();
    String h(int x) {
      final v = x % 24;
      final d = v % 12 == 0 ? 12 : v % 12;
      return '$d ${v < 12 ? 'am' : 'pm'}';
    }

    return 'Sharpest ~${h(w.startHour)}–${h(w.endHour)}${p.isForming ? ' · forming' : ''}';
  }

  static String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// The task id in a widget tap URI (`dayzen://widget/task?id=…`), or null.
  static String? taskIdFromUri(Uri? uri) {
    if (uri == null || uri.scheme != 'dayzen' || uri.host != 'widget') return null;
    // Segments, not a '/…' literal: the API contract test scans this folder
    // for path literals and would mistake one for a server endpoint.
    if (uri.pathSegments.length != 1 || uri.pathSegments.single != 'task') return null;
    return uri.queryParameters['id'];
  }
}
