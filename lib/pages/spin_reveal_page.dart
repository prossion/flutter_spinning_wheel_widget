import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/my_spinning_wheel.dart';
import '../widgets/spin_controller.dart';

class SpinRevealPage extends StatefulWidget {
  const SpinRevealPage({super.key});

  @override
  State<SpinRevealPage> createState() => _SpinRevealPageState();
}

class _SpinRevealPageState extends State<SpinRevealPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _overlayController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _overlayAnimation;
  bool _isSpinning = false;
  final MySpinController _spinController = MySpinController();
  final double _wheelSize = 450.0;
  String _currentResult = '';
  double _tiltAngle = 0;
  double _lastDividerPosition = 0;
  double _currentVelocity = 0;

  void _updateTiltBasedOnDivider(double currentRotation, double velocity) {
    final segmentAngle = 2 * math.pi / _spinController.itemList.length;
    final normalizedRotation = currentRotation % (2 * math.pi);
    final currentSegment = (normalizedRotation / segmentAngle).floor();
    final nextDivider = (currentSegment + 1) * segmentAngle;
    final prevDivider = currentSegment * segmentAngle;

    final distanceToNext = (nextDivider - normalizedRotation).abs();
    final distanceToPrev = (normalizedRotation - prevDivider).abs();

    final distanceToDivider =
        distanceToNext < distanceToPrev ? distanceToNext : distanceToPrev;
    _lastDividerPosition =
        distanceToNext < distanceToPrev ? nextDivider : prevDivider;

    final tiltRange = segmentAngle * 0.15;

    if (distanceToDivider < tiltRange) {
      final normalizedDistance = distanceToDivider / tiltRange;
      final tiltDirection = velocity > 0 ? -1.0 : 1.0;
      setState(() {
        _tiltAngle = tiltDirection * 0.4 * (1 - normalizedDistance);
      });
    } else {
      setState(() {
        _tiltAngle *= 0.8;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    );

    _spinController.setUpdateCallback((rotation) {
      _updateTiltBasedOnDivider(rotation, _currentVelocity);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  void _startSpinSequence() async {
    if (_isSpinning) return;
    _isSpinning = true;
    setState(() {});

    // Hide result overlay if visible
    _overlayController.reverse();
    await Future.delayed(const Duration(milliseconds: 300));

    // Slide in the wheel
    await _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // Scale up the wheel
    _scaleController.forward();

    // Start spinning after a short delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Random number of spins between 4 and 6 with longer duration for more natural feel
    final spins = math.Random().nextInt(3) + 4;
    final spinDuration = Duration(seconds: spins + 3);

    // Start the spin
    await _spinController.spinWithDuration(spinDuration);

    // Show result overlay
    await Future.delayed(const Duration(milliseconds: 300));
    _overlayController.forward();

    setState(() {
      _isSpinning = false;
    });
  }

  void _updateResult(String label) {
    _currentResult = label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1B3A),
      body: Stack(
        children: [
          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Animated wheel
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.center,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    MySpinner(
                      key: const ValueKey('spinner'),
                      mySpinController: _spinController,
                      wheelSize: _wheelSize,
                      onCurrentSegment: _updateResult,
                      onFinished: (_) {},
                      itemList: [
                        SpinItem(
                          label: '10% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                        SpinItem(
                          label: '20% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                        SpinItem(
                          label: '30% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                        SpinItem(
                          label: '40% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                        SpinItem(
                          label: '20% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                        SpinItem(
                          label: '10% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                        SpinItem(
                          label: '70% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                        SpinItem(
                          label: '30% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                        SpinItem(
                          label: '60% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                        SpinItem(
                          label: '90% Sale',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Result overlay
          FadeTransition(
            opacity: _overlayAnimation,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _currentResult,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Spin button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _isSpinning ? null : _startSpinSequence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _isSpinning ? 'Spinning...' : 'Spin!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
