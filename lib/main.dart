import 'package:flutter/material.dart';
import 'core/design_system/design_system.dart';
import 'features/onboarding/onboarding_page.dart';

void main() {
  runApp(const DayZenApp());
}

class DayZenApp extends StatelessWidget {
  const DayZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayZen',
      debugShowCheckedModeBanner: false,
      theme: DzTheme.light,
      darkTheme: DzTheme.dark,
      themeMode: ThemeMode.system,
      home: OnboardingPage(
        onDone: () {
          // TODO: Navigate to home once Home page is implemented
        },
        onEnableSync: () {
          // TODO: Navigate to sync setup screen
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Design System Preview — replace with real routing once pages are built
// ─────────────────────────────────────────────────────────────────────────────

class _DesignSystemPreview extends StatefulWidget {
  const _DesignSystemPreview();

  @override
  State<_DesignSystemPreview> createState() => _DesignSystemPreviewState();
}

class _DesignSystemPreviewState extends State<_DesignSystemPreview> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DzScaffold(
      currentIndex: _currentIndex,
      onNavTap: (i) {
        // Skip FAB index 2
        if (i == 2) return;
        setState(() => _currentIndex = i);
      },
      onFabPressed: () {},
      appBar: DzAppBar(
        title: 'DayZen',
        actions: [
          DzIconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(DzSpacing.md),
        children: [
          const DzGreeting(name: 'Alex'),
          const SizedBox(height: DzSpacing.md),
          const DzPrivacyBadge(),
          const SizedBox(height: DzSpacing.lg),

          const DzSectionHeader(title: 'Today\'s Tasks', actionLabel: 'See all'),
          const SizedBox(height: DzSpacing.sm),

          DzTaskBlock(
            title: 'Morning meditation',
            subtitle: '10 minutes',
            time: '07:00',
            priority: TaskPriority.low,
            onCompleteToggle: (_) {},
          ),
          const SizedBox(height: DzSpacing.sm),
          DzTaskBlock(
            title: 'Team standup',
            subtitle: 'Google Meet',
            time: '09:30',
            priority: TaskPriority.high,
            onCompleteToggle: (_) {},
          ),
          const SizedBox(height: DzSpacing.sm),
          DzTaskBlock(
            title: 'Write project proposal',
            time: '11:00',
            priority: TaskPriority.medium,
            isCompleted: true,
            onCompleteToggle: (_) {},
          ),
          const SizedBox(height: DzSpacing.lg),

          DzSectionCard(
            title: 'Productivity',
            subtitle: 'Today\'s overview',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatTile(value: '5', label: 'Tasks done'),
                _StatTile(value: '2', label: 'Remaining'),
                _StatTile(value: '83%', label: 'Focus score'),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.lg),

          const DzSectionHeader(title: 'Components'),
          const SizedBox(height: DzSpacing.sm),
          DzPrimaryButton(label: 'Primary Button', onPressed: () {}),
          const SizedBox(height: DzSpacing.sm),
          DzSecondaryButton(label: 'Secondary Button', onPressed: () {}),
          const SizedBox(height: DzSpacing.sm),
          DzGhostButton(label: 'Ghost Button', onPressed: () {}),
          const SizedBox(height: DzSpacing.md),
          const DzTextField(label: 'Task name', hint: 'Enter task...'),
          const SizedBox(height: DzSpacing.sm),
          const DzSearchField(hint: 'Search tasks...'),
          const SizedBox(height: DzSpacing.xl),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DzHeading2(value, color: DzColors.primary),
        const SizedBox(height: 2),
        DzSmallText(label),
      ],
    );
  }
}

