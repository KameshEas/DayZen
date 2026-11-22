/// User-facing text for onboarding v2 (plan M-1.6). Kept apart from
/// AppConfig so the flow's copy can be reviewed in one place.
abstract final class OnboardingV2Copy {
  // Step 0 · Welcome
  static const welcomeTitle = 'Plan today\nin 60 seconds';
  static const welcomeBody =
      'Tell DayZen what\'s on your mind. It finds a calm slot for each thing, '
      'and nothing unfinished ever turns into guilt.';
  static const welcomeBegin = "Let's begin";
  static const welcomeRestore = 'I have an account';
  static const welcomeSkip = 'Skip';

  // Step 1 · What's on your plate?
  static const plateTitle = "What's on your plate?";
  static const plateBody =
      'Type it the way you\'d say it. Times and lengths are optional.';
  static const plateHint = 'e.g. gym at 7, finish the report 2h, call mom after lunch';
  static const plateExamplesLabel = 'Try one';
  static const plateExamples = [
    'reply to emails 30 min',
    'gym at 6pm',
    'study for 1 hour',
    'call mom after lunch',
    'groceries',
    '10 min meditation',
  ];
  static const plateTurnIntoTasks = 'Turn into tasks';
  static const plateChipsLabel = 'Your tasks. Tap one to edit it.';
  static const plateAddTask = 'Add a task';
  static const plateSuggestionNote =
      'Couldn\'t spot a task in that, so here\'s a gentle start. Edit it or add your own.';

  // Step 2 · When are you sharpest?
  static const sharpestTitle = 'When are you sharpest?';
  static const sharpestBody =
      'A starting guess. DayZen learns your real rhythm as you go.';
  static const sharpestMorning = 'Morning';
  static const sharpestMorningHint = 'Clear-headed before lunch';
  static const sharpestMidday = 'Midday';
  static const sharpestMiddayHint = 'Up to speed by late morning';
  static const sharpestEvening = 'Evening';
  static const sharpestEveningHint = 'Best after the day settles';
  static const sharpestNotSure = 'Not sure';
  static const sharpestNotSureHint = "I'll figure it out with you";

  // Step 3 · Preview
  static const previewTitle = 'Your day, gently planned';
  static const previewBody = 'Focused work sits where your energy is highest. '
      'Drag a block to move it.';
  static const previewTomorrow = 'Tomorrow';
  static const previewMovedNote = 'No room left today';
  static const previewEmptyToday = 'Nothing left for today. Tomorrow is set.';

  // Step 4 · Gentle nudge?
  static const nudgeTitle = 'Gentle nudge?';
  static const nudgeBody =
      'A quiet reminder five minutes before each task. Never during your '
      'quiet hours, and you can turn it off in Settings.';
  static const nudgeYes = 'Yes, nudge me';
  static const nudgeNo = 'Not now';

  // Shared
  static const next = 'Next';
  static const looksGood = 'Looks good';
  static const back = 'Back';
  static const stepLabel = 'Step {n} of 4';
  static const editTaskTitle = 'Edit task';
  static const editTaskName = 'Task';
  static const editTaskLength = 'Length';
  static const editTaskTime = 'Time';
  static const editTaskAnyTime = 'Any time';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const remove = 'Remove';
}
