import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/quiz_question.dart';

enum NarrationState { idle, preparing, speaking, finished, failed }

enum QuizState { hidden, answering, success }

class StoryBuddyController extends ChangeNotifier {
  StoryBuddyController({FlutterTts? tts})
    : _tts = tts ?? FlutterTts(),
      quiz = QuizQuestion.fromJson(_quizPayload) {
    _configureSpeech();
  }

  static const storyText =
      'Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...';

  static const Map<String, Object?> _quizPayload = {
    'question': "What colour was Pip the Robot's lost gear?",
    'options': ['Red', 'Green', 'Blue', 'Yellow'],
    'answer': 'Blue',
  };

  final FlutterTts _tts;
  final QuizQuestion quiz;

  NarrationState narrationState = NarrationState.idle;
  QuizState quizState = QuizState.hidden;
  String? selectedOption;
  String? friendlyError;
  int wrongAttemptCount = 0;

  bool get canStartNarration =>
      narrationState != NarrationState.preparing &&
      narrationState != NarrationState.speaking;

  bool get shouldShowQuiz => quizState != QuizState.hidden;
  bool get isSuccess => quizState == QuizState.success;

  Future<void> _configureSpeech() async {
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.05);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {
      narrationState = NarrationState.failed;
      friendlyError = 'Story voice is warming up. Please try again.';
      notifyListeners();
      return;
    }

    _tts.setStartHandler(() {
      narrationState = NarrationState.speaking;
      notifyListeners();
    });

    _tts.setCompletionHandler(_showQuiz);
    _tts.setErrorHandler((message) {
      narrationState = NarrationState.failed;
      friendlyError = 'Pip needs one more try before reading aloud.';
      notifyListeners();
    });
  }

  Future<void> readStory() async {
    if (!canStartNarration) return;

    narrationState = NarrationState.preparing;
    quizState = QuizState.hidden;
    selectedOption = null;
    friendlyError = null;
    wrongAttemptCount = 0;
    notifyListeners();

    try {
      final result = await _tts.speak(storyText);
      if (result != 1 && narrationState != NarrationState.speaking) {
        narrationState = NarrationState.failed;
        friendlyError = 'Story voice is not ready yet. Tap again in a moment.';
        notifyListeners();
      }
    } catch (_) {
      narrationState = NarrationState.failed;
      friendlyError = 'Story voice is not ready yet. Tap again in a moment.';
      notifyListeners();
    }
  }

  void chooseAnswer(String option) {
    if (quizState == QuizState.success) return;

    selectedOption = option;
    if (quiz.isCorrect(option)) {
      quizState = QuizState.success;
    } else {
      quizState = QuizState.answering;
      wrongAttemptCount += 1;
    }
    notifyListeners();
  }

  void _showQuiz() {
    narrationState = NarrationState.finished;
    quizState = QuizState.answering;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
