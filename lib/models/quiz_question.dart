class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  final String question;
  final List<String> options;
  final String answer;

  factory QuizQuestion.fromJson(Map<String, Object?> json) {
    final rawOptions = json['options'];

    if (json['question'] is! String ||
        rawOptions is! List ||
        json['answer'] is! String) {
      throw const FormatException('Quiz payload is missing required fields.');
    }

    final options = rawOptions.map((item) => item.toString()).toList();
    if (options.length < 2) {
      throw const FormatException('Quiz needs at least two options.');
    }

    return QuizQuestion(
      question: json['question'] as String,
      options: List.unmodifiable(options),
      answer: json['answer'] as String,
    );
  }

  bool isCorrect(String option) {
    return option.trim().toLowerCase() == answer.trim().toLowerCase();
  }
}
