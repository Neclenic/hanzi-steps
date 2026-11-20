import 'dart:async';

import 'package:flutter/material.dart';

import '../logic/badges.dart';
import '../logic/progress.dart';

/// Watches progress and slides a small "New badge!" note in at the top of the screen
/// whenever a badge is earned.
class BadgeWatcher {
  final Progress progress;
  final GlobalKey<NavigatorState> navigator;
  BadgeWatcher(this.progress, this.navigator);

  OverlayEntry? _entry;
  Timer? _timer;

  void start() {
    progress.addListener(_check);
    _check();
  }

  void _check() {
    final earned = earnedBadges(progress);
    final seen = progress.badgesSeen;
    final fresh = earned.difference(seen);
    if (fresh.isEmpty) return;
    progress.setBadgesSeen({...seen, ...earned});
    // Wait for the current frame, so the note appears over the screen that earned it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _show(fresh.toList()));
  }

  void _show(List<String> ids) {
    final overlay = navigator.currentState?.overlay;
    if (overlay == null) return;
    _timer?.cancel();
    _entry?.remove();
    final first = badgeById(ids.first);
    final text = ids.length == 1 ? 'New badge: ${first.title}' : '${ids.length} new badges! See them on the Stats page.';
    final entry = OverlayEntry(builder: (context) => _Toast(emoji: first.emoji, text: text));
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(const Duration(milliseconds: 3200), () {
      if (_entry == entry) {
        entry.remove();
        _entry = null;
      }
    });
  }
}

class _Toast extends StatelessWidget {
  final String emoji;
  final String text;
  const _Toast({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, v, child) => Transform.translate(offset: Offset(0, -60 * (1 - v)), child: child),
            child: Material(
              elevation: 6,
              color: scheme.inverseSurface,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(text,
                        style: TextStyle(color: scheme.onInverseSurface, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
