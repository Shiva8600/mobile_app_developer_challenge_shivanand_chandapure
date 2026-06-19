import 'package:flutter/material.dart';

import '../theme/peblo_palette.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.story, required this.errorText});

  final String story;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
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
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _ModeBadge(text: 'PEBLO TV'),
                const SizedBox(width: 8),
                Text(
                  'Story snippet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: PebloPalette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              story,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: PebloPalette.ink,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: errorText == null
                  ? const SizedBox.shrink()
                  : Padding(
                      key: ValueKey(errorText),
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        errorText!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFB13B34),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ],
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
        color: PebloPalette.yellow,
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
