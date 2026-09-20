import 'package:dayzen/core/design_system/design_system.dart';
import 'package:dayzen/features/onboarding/widgets/onboarding_page_animated.dart';
import 'package:dayzen/features/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _fonts() async {
  Future<void> load(String family, List<String> files) async {
    final l = FontLoader(family);
    for (final f in files) {
      l.addFont(rootBundle.load('assets/fonts/$f'));
    }
    await l.load();
  }
  await load('Inter', ['Inter_18pt-Regular.ttf', 'Inter_18pt-Medium.ttf', 'Inter_18pt-SemiBold.ttf', 'Inter_18pt-Bold.ttf']);
  await load('InterDisplay', ['Inter_28pt-Regular.ttf', 'Inter_28pt-Medium.ttf', 'Inter_28pt-SemiBold.ttf', 'Inter_28pt-Bold.ttf']);
  await load('BodoniModa', ['BodoniModa-Variable.ttf']);
}

class _Showcase extends StatelessWidget {
  const _Showcase();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const DzLogo(width: 150), actions: const [Icon(Icons.settings_outlined), SizedBox(width: 16)]),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add_rounded)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Good morning', style: DzTextStyles.heading1),
        const SizedBox(height: 4),
        Text('Plan your day around what matters.', style: DzTextStyles.body.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Today', style: DzTextStyles.heading3.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: .6, color: cs.primary, backgroundColor: cs.outline),
          const SizedBox(height: 12),
          Row(children: [Chip(label: const Text('Focus')), const SizedBox(width: 8), Switch(value: true, onChanged: (_) {})]),
        ]))),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () {}, child: const Text('Start focus session')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () {}, child: const Text('Add task')),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(labelText: 'Task name', hintText: 'e.g. Deep work')),
        const SizedBox(height: 8),
        Row(children: [
          for (final c in [DzColors.navy, DzColors.sunrise, DzColors.slate, DzColors.mist, DzColors.zenGreen, DzColors.lavender])
            Expanded(child: Container(height: 28, margin: const EdgeInsets.all(2), color: c)),
        ]),
      ]),
    );
  }
}

void main() {
  setUpAll(_fonts);
  for (final dark in [false, true]) {
    final tag = dark ? 'dark' : 'light';
    ThemeData theme() => dark ? DzTheme.dark() : DzTheme.light();
    testWidgets('showcase $tag', (t) async {
      t.view.physicalSize = const Size(420, 860); t.view.devicePixelRatio = 1;
      await t.pumpWidget(MaterialApp(theme: theme(), home: const _Showcase()));
      await t.pump();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('showcase_$tag.png'));
    });
    testWidgets('splash $tag', (t) async {
      t.view.physicalSize = const Size(420, 860); t.view.devicePixelRatio = 1;
      await t.pumpWidget(MaterialApp(theme: theme(), home: SplashPage(onFinished: () {})));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await t.pump();
      await t.pump(const Duration(milliseconds: 1900));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('splash_$tag.png'));
      await t.pump(const Duration(seconds: 3));
    });
    if (!dark) testWidgets('onboarding $tag', (t) async {
      t.view.physicalSize = const Size(420, 860); t.view.devicePixelRatio = 1;
      await t.pumpWidget(MaterialApp(theme: DzTheme.light(), home: const AnimatedOnboardingPage()));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await t.pump(const Duration(seconds: 2));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('onboarding_1.png'));
      for (var i = 0; i < 5; i++) { await t.tap(find.textContaining(RegExp('Next|Continue')).first); await t.pump(const Duration(seconds: 2)); }
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('onboarding_6.png'));
    });
  }
}
