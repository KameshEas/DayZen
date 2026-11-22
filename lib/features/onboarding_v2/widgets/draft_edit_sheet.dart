import 'package:flutter/material.dart';

import '../../../core/config/copy/onboarding_v2_copy.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/domain/brain_dump_parser.dart';

/// Edits one onboarding task chip: name, length and time. Returns the edited
/// draft, or null when cancelled.
Future<TaskDraft?> showDraftEditSheet(BuildContext context, TaskDraft draft) {
  return showModalBottomSheet<TaskDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _DraftEditSheet(draft: draft),
  );
}

/// "1h 30m", "45 min".
String formatDuration(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

/// "9:30 AM".
String formatMinuteOfDay(int minute) {
  final m = minute.clamp(0, 24 * 60 - 1);
  final h = m ~/ 60;
  final min = m % 60;
  final suffix = h < 12 ? 'AM' : 'PM';
  final display = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$display:${min.toString().padLeft(2, '0')} $suffix';
}

class _DraftEditSheet extends StatefulWidget {
  const _DraftEditSheet({required this.draft});
  final TaskDraft draft;

  @override
  State<_DraftEditSheet> createState() => _DraftEditSheetState();
}

class _DraftEditSheetState extends State<_DraftEditSheet> {
  static const _lengths = [15, 30, 45, 60, 90, 120];

  late final TextEditingController _title =
      TextEditingController(text: widget.draft.title);
  late int _duration = widget.draft.durationMinutes;
  late int? _start = widget.draft.startMinute;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final initial = _start ?? 9 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    if (picked != null && mounted) {
      setState(() => _start = picked.hour * 60 + picked.minute);
    }
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop(widget.draft.copyWith(
      title: title,
      durationMinutes: _duration,
      startMinute: _start,
      clearTime: _start == null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lengths = {..._lengths, _duration}.toList()..sort();
    return Padding(
      padding: EdgeInsets.fromLTRB(DzSpacing.lg, 0, DzSpacing.lg,
          DzSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(OnboardingV2Copy.editTaskTitle, style: DzTextStyles.heading3),
          const SizedBox(height: DzSpacing.md),
          TextField(
            controller: _title,
            autofocus: true,
            maxLength: BrainDumpParser.maxTitleLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: OnboardingV2Copy.editTaskName,
              counterText: '',
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: DzSpacing.md),
          Text(OnboardingV2Copy.editTaskLength,
              style: DzTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: DzSpacing.xs),
          Wrap(
            spacing: DzSpacing.sm,
            runSpacing: DzSpacing.xs,
            children: [
              for (final l in lengths)
                ChoiceChip(
                  label: Text(formatDuration(l)),
                  selected: _duration == l,
                  onSelected: (_) => setState(() => _duration = l),
                ),
            ],
          ),
          const SizedBox(height: DzSpacing.md),
          Text(OnboardingV2Copy.editTaskTime,
              style: DzTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: DzSpacing.xs),
          Wrap(
            spacing: DzSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text(OnboardingV2Copy.editTaskAnyTime),
                selected: _start == null,
                onSelected: (_) => setState(() => _start = null),
              ),
              ChoiceChip(
                avatar: const Icon(Icons.schedule_rounded, size: 18),
                label: Text(_start == null
                    ? OnboardingV2Copy.editTaskTime
                    : formatMinuteOfDay(_start!)),
                selected: _start != null,
                onSelected: (_) => _pickTime(),
              ),
            ],
          ),
          const SizedBox(height: DzSpacing.lg),
          Row(
            children: [
              Expanded(
                child: DzSecondaryButton(
                  label: OnboardingV2Copy.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: DzSpacing.sm),
              Expanded(
                child: DzPrimaryButton(
                  label: OnboardingV2Copy.save,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
