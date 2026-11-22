import 'package:flutter/material.dart';

import '../../../core/config/copy/onboarding_v2_copy.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/domain/brain_dump_parser.dart';
import '../onboarding_controller.dart';
import 'draft_edit_sheet.dart';
import 'onboarding_scaffold.dart';

/// Step 1: "What's on your plate?" — a text box and example chips that turn
/// into editable task chips.
class PlateStep extends StatefulWidget {
  const PlateStep({super.key, required this.controller});
  final OnboardingController controller;

  @override
  State<PlateStep> createState() => _PlateStepState();
}

class _PlateStepState extends State<PlateStep> {
  late final TextEditingController _text =
      TextEditingController(text: widget.controller.dumpText);

  OnboardingController get c => widget.controller;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _addExample(String example) {
    c.addExample(example);
    _text.value = TextEditingValue(
      text: c.dumpText,
      selection: TextSelection.collapsed(offset: c.dumpText.length),
    );
  }

  void _turnIntoTasks() {
    FocusScope.of(context).unfocus();
    c.parseDump();
  }

  Future<void> _edit(int index) async {
    final edited = await showDraftEditSheet(context, c.drafts[index]);
    if (edited != null) c.updateDraft(index, edited);
  }

  Future<void> _add() async {
    final edited = await showDraftEditSheet(
      context,
      const TaskDraft(title: ''),
    );
    if (edited != null) c.addDraft(edited);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final drafts = c.drafts;
    final onlySuggestion = drafts.length == 1 && drafts.single.isSuggestion;

    return OnboardingStepFrame(
      stepNumber: 1,
      title: OnboardingV2Copy.plateTitle,
      body: OnboardingV2Copy.plateBody,
      onBack: c.back,
      actions: DzPrimaryButton(
        label: OnboardingV2Copy.next,
        onPressed: c.canContinueFromPlate ? c.continueFromPlate : null,
        width: double.infinity,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _text,
            onChanged: c.setDumpText,
            minLines: 3,
            maxLines: 6,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: OnboardingV2Copy.plateHint,
              counterText: '',
              filled: true,
              fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DzRadius.card),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: DzSpacing.sm),
          Text(
            OnboardingV2Copy.plateExamplesLabel,
            style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: DzSpacing.xs),
          Wrap(
            spacing: DzSpacing.sm,
            runSpacing: DzSpacing.xs,
            children: [
              for (final e in OnboardingV2Copy.plateExamples)
                ActionChip(
                  label: Text(e),
                  tooltip: 'Add "$e"',
                  onPressed: () => _addExample(e),
                ),
            ],
          ),
          const SizedBox(height: DzSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: DzSecondaryButton(
              label: OnboardingV2Copy.plateTurnIntoTasks,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              onPressed: _turnIntoTasks,
            ),
          ),
          if (drafts.isNotEmpty) ...[
            const SizedBox(height: DzSpacing.lg),
            Text(
              onlySuggestion
                  ? OnboardingV2Copy.plateSuggestionNote
                  : OnboardingV2Copy.plateChipsLabel,
              style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: DzSpacing.sm),
            Wrap(
              spacing: DzSpacing.sm,
              runSpacing: DzSpacing.sm,
              children: [
                for (var i = 0; i < drafts.length; i++)
                  _DraftChip(
                    draft: drafts[i],
                    onTap: () => _edit(i),
                    onRemove: () => c.removeDraft(i),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(OnboardingV2Copy.plateAddTask),
                  onPressed: _add,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DraftChip extends StatelessWidget {
  const _DraftChip({
    required this.draft,
    required this.onTap,
    required this.onRemove,
  });

  final TaskDraft draft;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final time = draft.startMinute == null
        ? null
        : '${draft.timeIsApproximate ? '~' : ''}${formatMinuteOfDay(draft.startMinute!)}';
    final day = draft.dayOffset == 1 ? 'tomorrow' : null;
    final details = [
      ?time,
      formatDuration(draft.durationMinutes),
      ?day,
    ].join(' · ');
    return Semantics(
      label: '${draft.title}, $details. Double tap to edit.',
      excludeSemantics: true,
      child: InputChip(
        label: Text('${draft.title}  ·  $details'),
        onPressed: onTap,
        onDeleted: onRemove,
        deleteButtonTooltipMessage: '${OnboardingV2Copy.remove} ${draft.title}',
      ),
    );
  }
}
