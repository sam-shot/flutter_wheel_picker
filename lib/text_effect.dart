import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedNumberTextWithBlur extends StatefulWidget {
  final int value;

  const AnimatedNumberTextWithBlur({super.key, required this.value});

  @override
  State<AnimatedNumberTextWithBlur> createState() =>
      _AnimatedNumberTextWithBlurState();
}

class _AnimatedNumberTextWithBlurState
    extends State<AnimatedNumberTextWithBlur> {
  late int _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(AnimatedNumberTextWithBlur oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousValue = oldWidget.value;
  }

  @override
  Widget build(BuildContext context) {
    final String valueStr = widget.value.toString();
    final String prevStr = _previousValue.toString();

    final int maxLength =
        valueStr.length > prevStr.length ? valueStr.length : prevStr.length;
    final String paddedValue = valueStr.padLeft(maxLength, '0');
    final String paddedPrev = prevStr.padLeft(maxLength, '0');

    // Track which digits should animate
    List<bool> animateFlags = List.generate(maxLength, (_) => false);
    List<bool> previousDigitFlags = List.generate(maxLength, (_) => false);

    for (int index = 0; index < maxLength; index++) {
      if (index == maxLength - 1) {
        animateFlags[index] = true;
      } else {
        final int currentNext = int.parse(paddedValue[index + 1]);
        final int previousNext = int.parse(paddedPrev[index + 1]);

        if ((previousNext == 9 && currentNext == 0) ||
            (previousNext == 0 && currentNext == 9) ||
            (currentNext != previousNext)) {
          animateFlags[index] = true;
        }
      }
    }

    // Mark the digit before a changed one as "previous digit"
    for (int i = maxLength - 1; i > 0; i--) {
      if (animateFlags[i]) {
        previousDigitFlags[i - 1] = true;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLength, (index) {
        final int currentDigit = int.parse(paddedValue[index]);
        final int previousDigit = int.parse(paddedPrev[index]);

        return _AnimatedDigit(
          currentDigit: currentDigit,
          previousDigit: previousDigit,
          shouldAnimate: animateFlags[index] || previousDigitFlags[index],
          isPreviousDigit: previousDigitFlags[index],
        );
      }),
    );
  }
}

class _AnimatedDigit extends StatelessWidget {
  final int currentDigit;
  final int previousDigit;
  final bool shouldAnimate;
  final bool isPreviousDigit;

  const _AnimatedDigit({
    required this.currentDigit,
    required this.previousDigit,
    required this.shouldAnimate,
    required this.isPreviousDigit,
  });

  @override
  Widget build(BuildContext context) {
    if (!shouldAnimate) {
      return Text(
        '$currentDigit',
        style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
      );
    }

    final duration =
        isPreviousDigit
            ? const Duration(milliseconds: 400)
            : const Duration(milliseconds: 250);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: previousDigit.toDouble(),
        end: currentDigit.toDouble(),
      ),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, double animatedValue, child) {
        final int displayedValue = animatedValue.round();
        double blurBase = (animatedValue - currentDigit).abs();

        double blurRadius =
            isPreviousDigit
                ? blurBase *
                    3.5 // Stronger blur for previous digit
                : blurBase * 2.0;

        if (blurRadius < 0) blurRadius = 0;

        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
          child: Text(
            '$displayedValue',
            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
