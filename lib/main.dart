import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/story_buddy_controller.dart';
import 'theme/peblo_palette.dart';
import 'widgets/buddy_hero.dart';
import 'widgets/quiz_card.dart';
import 'widgets/story_card.dart';

void main() {
  runApp(const PebloStoryApp());
}

class PebloStoryApp extends StatelessWidget {
  const PebloStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryBuddyController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Peblo Story Buddy',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: PebloPalette.blue,
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
        ),
        home: const StoryBuddyScreen(),
      ),
    );
  }
}

class StoryBuddyScreen extends StatefulWidget {
  const StoryBuddyScreen({super.key});

  @override
  State<StoryBuddyScreen> createState() => _StoryBuddyScreenState();
}

class _StoryBuddyScreenState extends State<StoryBuddyScreen> {
  late final ConfettiController _confetti;
  bool _playedSuccessBurst = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<StoryBuddyController, bool>(
      selector: (_, controller) => controller.isSuccess,
      builder: (context, isSuccess, child) {
        if (isSuccess && !_playedSuccessBurst) {
          _playedSuccessBurst = true;
          _confetti.play();
        } else if (!isSuccess) {
          _playedSuccessBurst = false;
        }
        return child!;
      },
      child: Scaffold(
        backgroundColor: PebloPalette.cream,
        body: Stack(
          children: [
            const _Backdrop(),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: const SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: _StoryBuddyContent(),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: .08,
                numberOfParticles: 22,
                gravity: .18,
                shouldLoop: false,
                colors: const [
                  Color(0xFFFFC64D),
                  PebloPalette.green,
                  PebloPalette.blue,
                  PebloPalette.coral,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryBuddyContent extends StatelessWidget {
  const _StoryBuddyContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StoryBuddyController>();
    final isSpeaking = controller.narrationState == NarrationState.speaking;
    final isPreparing = controller.narrationState == NarrationState.preparing;

    return Column(
      children: [
        const _PebloHeader(),
        const SizedBox(height: 18),
        const _WorldStrip(),
        const SizedBox(height: 20),
        BuddyHero(
          isHappy: controller.isSuccess,
          isListening: isSpeaking || isPreparing,
        ),
        const SizedBox(height: 18),
        Text(
          controller.isSuccess
              ? 'Great listening, story explorer!'
              : 'AI Buddy is ready with a tiny tale from Peblo TV.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: PebloPalette.ink,
            fontWeight: FontWeight.w800,
            height: 1.22,
          ),
        ),
        const SizedBox(height: 18),
        _ReadButton(
          isBusy: isPreparing || isSpeaking,
          onPressed: controller.canStartNarration ? controller.readStory : null,
        ),
        const SizedBox(height: 20),
        StoryCard(
          story: StoryBuddyController.storyText,
          errorText: controller.friendlyError,
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 360),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: controller.shouldShowQuiz
              ? QuizCard(
                  key: const ValueKey('quiz-card'),
                  quiz: controller.quiz,
                  selectedOption: controller.selectedOption,
                  wrongAttemptCount: controller.wrongAttemptCount,
                  isSuccess: controller.isSuccess,
                  onAnswer: controller.chooseAnswer,
                )
              : const SizedBox(key: ValueKey('quiz-hidden')),
        ),
      ],
    );
  }
}

class _ReadButton extends StatelessWidget {
  const _ReadButton({required this.isBusy, required this.onPressed});

  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: isBusy
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow_rounded),
        label: Text(isBusy ? 'Getting Pip ready...' : 'Read Me a Story'),
        style: FilledButton.styleFrom(
          backgroundColor: PebloPalette.ink,
          foregroundColor: PebloPalette.paper,
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}

class _PebloHeader extends StatelessWidget {
  const _PebloHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: PebloPalette.paper,
            border: Border.all(color: PebloPalette.ink, width: 2),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2217213B),
                blurRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 18,
                  width: 18,
                  decoration: const BoxDecoration(
                    color: PebloPalette.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'peblo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: PebloPalette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Pip Story Buddy',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: PebloPalette.ink,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "India's AI-powered learning playground",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: PebloPalette.mutedInk,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _WorldStrip extends StatelessWidget {
  const _WorldStrip();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: const [
        _WorldChip(
          icon: Icons.smart_toy_rounded,
          label: 'AI Buddy',
          color: PebloPalette.sky,
        ),
        _WorldChip(
          icon: Icons.auto_stories_rounded,
          label: 'Peblo TV',
          color: PebloPalette.yellow,
        ),
        _WorldChip(
          icon: Icons.quiz_rounded,
          label: 'Quiz World',
          color: PebloPalette.lavender,
        ),
      ],
    );
  }
}

class _WorldChip extends StatelessWidget {
  const _WorldChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: PebloPalette.ink, width: 1.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: PebloPalette.ink),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: PebloPalette.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackdropPainter(), size: Size.infinite);
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF8E7), PebloPalette.cream],
      ).createShader(Offset.zero & size);
    final hillPaint = Paint()..color = const Color(0xFFCFF3BA);
    final sunPaint = Paint()..color = PebloPalette.yellow;
    final dotPaint = Paint()..color = const Color(0x22FF7168);
    final path = Path()
      ..moveTo(0, size.height * .82)
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .72,
        size.width * .56,
        size.height * .84,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .94,
        size.width,
        size.height * .78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawRect(Offset.zero & size, skyPaint);
    canvas.drawCircle(
      Offset(size.width * .86, size.height * .12),
      46,
      sunPaint,
    );
    canvas.drawCircle(Offset(size.width * .12, size.height * .16), 8, dotPaint);
    canvas.drawCircle(Offset(size.width * .22, size.height * .08), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * .78, size.height * .22), 6, dotPaint);
    canvas.drawPath(path, hillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
