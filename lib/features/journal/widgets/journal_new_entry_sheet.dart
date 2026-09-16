import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../app_data.dart';
import '../models/journal_entry.dart';

class JournalNewEntrySheet extends StatefulWidget {
  const JournalNewEntrySheet({super.key});

  @override
  State<JournalNewEntrySheet> createState() => _JournalNewEntrySheetState();
}

class _JournalNewEntrySheetState extends State<JournalNewEntrySheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  JournalMood _selectedMood = JournalMood.happy;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: DzColors.cardBackground,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(DzRadius.modal)),
        ),
        padding: const EdgeInsets.fromLTRB(
            DzSpacing.lg, DzSpacing.lg, DzSpacing.lg, DzSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: DzColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.lg),
            Text('New Entry',
                style: DzTextStyles.heading3
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DzSpacing.md),
            // Mood picker
            Row(
              children: JournalMood.values.map((mood) {
                final selected = _selectedMood == mood;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood),
                    child: AnimatedContainer(
                      duration: DzDuration.fast,
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? mood.bg : DzColors.appBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? Border.all(color: mood.iconColor, width: 1.5)
                            : Border.all(
                                color: DzColors.borderLight, width: 1),
                      ),
                      child: Icon(mood.icon,
                          color: mood.iconColor,
                          size: selected ? 24 : 20),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: DzSpacing.md),
            DzTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'What\'s on your mind?',
            ),
            const SizedBox(height: DzSpacing.md),
            DzTextField(
              controller: _bodyController,
              label: 'Write your thoughtsâ€¦',
              hint: '',
              maxLines: 4,
            ),
            const SizedBox(height: DzSpacing.lg),
            DzPrimaryButton(
              label: 'Save Entry',
              onPressed: () {
                final title = _titleController.text.trim();
                final body = _bodyController.text.trim();
                if (title.isEmpty) return;
                final entry = JournalEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  body: body.isEmpty ? '' : body,
                  mood: _selectedMood,
                  timestamp: DateTime.now(),
                  accentColor: _selectedMood.iconColor,
                );
                JournalScope.of(context).addEntry(entry);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}



