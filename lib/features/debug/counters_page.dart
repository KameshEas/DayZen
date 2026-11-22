import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system/design_system.dart';
import '../../core/data/database/db_encryption.dart';
import '../../core/services/counters_service.dart';

/// Tester-only counters screen (plan M-1.11). Hidden: opened by tapping the
/// app version in Settings seven times. Everything shown here lives only on
/// this phone; "Copy for feedback" puts plain counts on the clipboard for the
/// tester to paste into their form by hand. No network calls.
class CountersPage extends StatefulWidget {
  const CountersPage({super.key});

  @override
  State<CountersPage> createState() => _CountersPageState();
}

class _CountersPageState extends State<CountersPage> {
  late Future<({Map<String, int> counts, List<int> ttfp, List<int> dbOpen})> _data =
      _load();

  Future<({Map<String, int> counts, List<int> ttfp, List<int> dbOpen})> _load() async => (
        counts: await CountersService.instance.snapshot(),
        ttfp: await CountersService.instance.ttfpSamples(),
        dbOpen: await DbEncryption.openSamples(),
      );

  Future<void> _copy() async {
    final json = await CountersService.instance.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied. Paste it into your feedback form.')),
    );
  }

  static String _label(String key) => key
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: DzAppBar(
        title: 'Tester counters',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _data = _load()),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _data,
        builder: (context, snap) {
          final d = snap.data;
          if (d == null) return const Center(child: CircularProgressIndicator());
          final median = CountersService.median(d.ttfp);
          return ListView(
            padding: const EdgeInsets.all(DzSpacing.md),
            children: [
              Text(
                'Counts only, never content. Nothing here leaves this phone '
                'unless you copy it.',
                style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: DzSpacing.md),
              for (final e in d.counts.entries)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(_label(e.key)),
                  trailing: Text('${e.value}',
                      style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                ),
              const Divider(),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Time to first plan (median)'),
                subtitle: Text('${d.ttfp.length} samples'),
                trailing: Text(
                  median == null ? '—' : '${(median / 1000).toStringAsFixed(1)} s',
                  style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Encrypted database open (median)'),
                subtitle: Text('${d.dbOpen.length} starts · for the cold-start benchmark'),
                trailing: Text(
                  CountersService.median(d.dbOpen) == null
                      ? '—'
                      : '${CountersService.median(d.dbOpen)} ms',
                  style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: DzSpacing.lg),
              DzPrimaryButton(
                label: 'Copy for feedback',
                icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white),
                onPressed: _copy,
                width: double.infinity,
              ),
            ],
          );
        },
      ),
    );
  }
}
