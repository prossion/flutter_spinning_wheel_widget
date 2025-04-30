import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'my_spinning_wheel.dart';

class MySpinController {
  AnimationController? _baseAnimation;
  late TickerProvider _tickerProvider;
  bool _xSpinning = false;
  List<SpinItem> itemList = [];
  double _velocity = 0;
  Function(double)? _onAnimationUpdate;

  Future<void> initLoad({
    required TickerProvider tickerProvider,
    required List<SpinItem> itemList,
  }) async {
    _tickerProvider = tickerProvider;
    this.itemList = itemList;
    await setAnimations(_tickerProvider);
  }

  Future<void> setAnimations(TickerProvider tickerProvider) async {
    _baseAnimation = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 200),
    );
  }

  void setUpdateCallback(Function(double) callback) {
    _onAnimationUpdate = callback;
  }

  Future<void> spinWithDuration(Duration duration) async {
    if (_baseAnimation == null) return;

    if (!_xSpinning) {
      _xSpinning = true;

      // Calculate total rotation based on duration
      final totalRotations =
          (duration.inMilliseconds / 1000) * 2; // 2 rotations per second
      // Add a random offset to ensure it can stop anywhere
      final randomOffset = math.Random().nextDouble() * 2 * math.pi;
      final targetRotation = (totalRotations * 2 * math.pi) + randomOffset;

      _baseAnimation!.duration = duration;
      _baseAnimation!.reset();

      // Create a curved animation for natural deceleration
      final curvedAnimation = CurvedAnimation(
        parent: _baseAnimation!,
        curve: Curves.easeInOut,
      );

      // Add listener for continuous rotation update with curved animation
      void updateListener() {
        if (_onAnimationUpdate != null) {
          // Apply additional easing to make the end more natural
          final value = curvedAnimation.value;
          final easedValue = _applyCustomEasing(value);
          _onAnimationUpdate!(easedValue * targetRotation);
        }
      }

      _baseAnimation!.addListener(updateListener);

      await _baseAnimation!.forward();

      _baseAnimation!.removeListener(updateListener);
      _xSpinning = false;
    }
  }

  double _applyCustomEasing(double value) {
    // Custom easing function to make deceleration more natural
    if (value < 0.7) {
      // First 70% of the animation - maintain regular speed
      return value;
    } else {
      // Last 30% - apply custom deceleration
      final normalizedValue = (value - 0.7) / 0.3; // normalize to 0-1 range
      final deceleration = 1 - (1 - normalizedValue) * (1 - normalizedValue);
      return 0.7 + (deceleration * 0.3);
    }
  }

  Future<void> spinNow({
    required int luckyIndex,
    int totalSpin = 10,
    int baseSpinDuration = 100,
  }) async {
    if (_baseAnimation == null) return;

    int itemsLength = itemList.length;
    int factor = luckyIndex % itemsLength;
    if (factor == 0) factor = itemsLength;
    double spinInterval = 1 / itemsLength;
    double target = 1 - ((spinInterval * factor) - (spinInterval / 2));

    if (!_xSpinning) {
      _xSpinning = true;
      int spinCount = 0;

      do {
        _baseAnimation!.reset();
        _baseAnimation!.duration = Duration(milliseconds: baseSpinDuration);
        if (spinCount == totalSpin) {
          await _baseAnimation!.animateTo(target);
        } else {
          await _baseAnimation!.forward();
        }
        baseSpinDuration = baseSpinDuration + 50;
        _baseAnimation!.duration = Duration(milliseconds: baseSpinDuration);
        spinCount++;
      } while (spinCount <= totalSpin);

      _xSpinning = false;
    }
  }

  Future<void> dispose() async {
    if (_baseAnimation?.isAnimating == true) {
      _baseAnimation?.stop();
    }
    _baseAnimation?.dispose();
  }

  AnimationController? get baseAnimation => _baseAnimation;
}
