# Peblo Story Buddy

A single-screen Flutter prototype for Peblo's intern challenge. The app reads a short Pip story aloud, then reveals a quiz rendered from a backend-style JSON payload.

## Framework Choice

I chose Flutter because the brief calls out mid-range Android devices, and Flutter gives a consistent UI and animation stack across Android and iOS without maintaining two views. The feature is intentionally small: one screen, a `ChangeNotifier` controller, and a few focused widgets.

## Run It

```bash
flutter pub get
flutter run
```

The current workspace was created by writing files directly, so if you want platform folders generated locally, run:

```bash
flutter create --platforms=android,ios .
```

## Feature Flow

1. The child taps **Read Me a Story**.
2. `StoryBuddyController` moves from `idle` to `preparing`, then to `speaking` when `flutter_tts` starts.
3. When the TTS completion callback fires, the controller sets narration to `finished` and reveals the quiz with an `AnimatedSwitcher`.
4. Wrong answers increment an attempt counter. `QuizCard` watches that counter and runs a shake animation with haptic feedback.
5. The correct answer moves the quiz to `success`, changes Pip's face, marks the right option, and plays confetti.

## Visual Direction

The UI is styled to feel like it belongs to the Peblo universe shown on `mypeblo.com`: warm cream backgrounds, bold dark outlines, bright world colors, mode labels such as **AI Buddy**, **Peblo TV**, and **Quiz World**, and copy that echoes Peblo's "AI-powered learning playground" positioning. The mascot is drawn with `CustomPainter` so the screen keeps the brand-like character feel without adding heavy image assets.

## Data-Driven Quiz

The quiz is parsed through `QuizQuestion.fromJson`, not built directly in the widget. The renderer loops through `quiz.options`, so the same UI works for 3, 4, or 5 options without code changes.

```dart
static const Map<String, Object?> _quizPayload = {
  'question': "What colour was Pip the Robot's lost gear?",
  'options': ['Red', 'Green', 'Blue', 'Yellow'],
  'answer': 'Blue',
};
```

If a payload is malformed, the model throws a `FormatException` early instead of leaving the UI in a strange state.

## Audio And Failure Handling

The app uses `flutter_tts`, which routes to the device TTS engine. The UI has separate `preparing`, `speaking`, `finished`, and `failed` states. If `speak` throws or returns an unexpected result, the child sees a short friendly retry message and the button becomes available again.

For remote audio, I would cache by a stable key such as `storyId + voiceId + locale + storyTextHash`. The first request would save the MP3/AAC file to the app cache directory. Later plays would use the local file while a background refresh checks whether the story or voice changed.

## Performance Notes

The screen avoids large image assets and uses `CustomPainter` for the buddy and background. The animations are short, GPU-friendly transforms/fades, and the quiz card only shakes when the wrong-attempt counter changes. The controller is exposed through Provider so state changes stay simple and predictable.

What I would profile before submission:

- Flutter DevTools frame chart during TTS completion, quiz reveal, wrong-answer shake, and confetti.
- Memory on a 3GB Android device or emulator after repeated story retries.
- Raster time during confetti. If it spikes, reduce particles or shorten the burst.

## AI Usage And Judgment

I used AI assistance to speed up the first project structure and remind myself of the challenge checklist. I rejected the suggestion to add a heavy illustrated asset pack because the target includes modest Android devices and the prototype does not need that cost. The better version here is a painted buddy: light, cheerful, and easy to maintain.

One thing that did not work in this workspace was relying on `flutter create`; the local Flutter wrapper needed access to SDK/tool-state folders outside the sandbox. I handled that by writing the project files directly and keeping the structure conventional.
