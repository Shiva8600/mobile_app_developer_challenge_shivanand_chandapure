import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/quiz_question.dart';
import '../theme/peblo_palette.dart';

class QuizCard extends StatefulWidget {
  const QuizCard({
    super.key,
    required this.quiz,
    required this.selectedOption,
    required this.wrongAttemptCount,
    required this.isSuccess,
    required this.onAnswer,
  });

  final QuizQuestion quiz;
  final String? selectedOption;
  final int wrongAttemptCount;
  final bool isSuccess;
  final ValueChanged<String> onAnswer;

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shake = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wrongAttemptCount > oldWidget.wrongAttemptCount) {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shake.value, 0),
          child: child,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PebloPalette.paper,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: PebloPalette.ink, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2217213B),
              blurRadius: 0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ModeBadge(text: 'QUIZ WORLD'),
              const SizedBox(height: 12),
              Text(
                widget.isSuccess ? 'You found it!' : widget.quiz.question,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: PebloPalette.ink,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useTwoColumns =
                      constraints.maxWidth > 430 &&
                      widget.quiz.options.length > 3;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final option in widget.quiz.options)
                        SizedBox(
                          width: useTwoColumns
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth,
                          child: _AnswerChip(
                            label: option,
                            isSelected: widget.selectedOption == option,
                            isSuccess:
                                widget.isSuccess &&
                                widget.quiz.isCorrect(option),
                            onTap: () => widget.onAnswer(option),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({
    required this.label,
    required this.isSelected,
    required this.isSuccess,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isSuccess;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isSuccess
        ? PebloPalette.green
        : isSelected
        ? const Color(0xFFFFD7D2)
        : PebloPalette.cream;
    final foreground = PebloPalette.ink;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSuccess ? PebloPalette.ink : const Color(0x3317213B),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isSuccess)
                const Icon(Icons.check_circle_rounded, color: PebloPalette.ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PebloPalette.lavender,
        border: Border.all(color: PebloPalette.ink, width: 1.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: PebloPalette.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
