import 'package:flutter_test/flutter_test.dart';
import 'package:peblo_story_buddy/models/quiz_question.dart';

void main() {
  test('builds a quiz from a backend-style payload', () {
    final quiz = QuizQuestion.fromJson(const {
      'question': 'Which moon did Tara visit?',
      'options': ['Io', 'Europa', 'Titan'],
      'answer': 'Europa',
    });

    expect(quiz.question, 'Which moon did Tara visit?');
    expect(quiz.options, hasLength(3));
    expect(quiz.isCorrect('europa'), isTrue);
  });

  test('rejects unusable quiz payloads', () {
    expect(
      () => QuizQuestion.fromJson(const {
        'question': 'Pick one',
        'options': ['Only one'],
        'answer': 'Only one',
      }),
      throwsFormatException,
    );
  });
}
