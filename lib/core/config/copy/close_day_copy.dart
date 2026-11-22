/// User-facing text for Close the Day (plan M-1.10) and the Released list
/// (M-1.12). Calm wording only: nothing here frames an unfinished task as
/// late, missed or failed.
abstract final class CloseDayCopy {
  static const pageTitle = 'Close your day';

  // Step 1 · review
  static const reviewTitle = "What's still open?";
  static const reviewBody =
      'Swipe right to carry it to tomorrow, left to let it go, or tap if it '
      'got done. All fine choices.';
  static const reviewEmpty = 'Nothing left open. Nicely done.';
  static const carry = 'Tomorrow';
  static const letGo = 'Let go';
  static const done = 'Done';
  static const undo = 'Undo';
  static const carriedHint = 'Carried {n}×';

  // Step 2 · mood
  static const moodTitle = 'How did today feel?';
  static const moodBody = 'One tap. There is no wrong answer.';

  // Step 3 · note
  static const noteTitle = 'Anything to remember?';
  static const noteBody = 'Optional. One line is plenty. It goes in your journal.';
  static const noteHint = 'e.g. Good focus after lunch';
  static const noteDraftHelper = 'Drafted from your day. Edit it, or clear it.';
  static const closeButton = 'Close the day';
  static const skipNote = 'Close without a note';

  // Step 4 · summary
  static const summaryTitle = 'Day closed.';
  static const summaryEditedTitle = 'Day updated.';
  static const summaryBody = 'Rest well. Tomorrow starts fresh.';
  static const summaryDone = 'Back to DayZen';

  // Home card
  static const homeCardTitle = 'Close your day';
  static const homeCardBody = 'A minute to sort what\'s left and note how it felt.';
  static const homeCardAction = 'Start';
  static const homeCardClosed = 'Day closed';
  static const firstEveningTitle = 'Your first evening with DayZen';
  static const firstEveningBody =
      'Close the day: sort what’s left and note how it felt. A minute, no more.';

  // "What's new" card for existing installs (M-1.8)
  static const whatsNewTitle = 'New: Close your day';
  static const whatsNewBody =
      'Each evening, sort what\'s left in a few swipes. Unfinished tasks carry '
      'over gently, so nothing piles up.';
  static const whatsNewTry = 'Try it';
  static const whatsNewDismiss = 'Got it';

  // Settings
  static const settingsReminder = 'Evening "close your day" prompt';
  static const settingsReminderHint = 'Skipped if it falls in your quiet hours.';

  // Released list (M-1.12)
  static const releasedTitle = 'Let go';
  static const releasedBody =
      'Things you chose to let go. Bring one back any time, or clear it away.';
  static const releasedEmpty = 'Nothing here. Letting go is always an option.';
  static const bringBack = 'Bring back';
  static const delete = 'Delete';
}
