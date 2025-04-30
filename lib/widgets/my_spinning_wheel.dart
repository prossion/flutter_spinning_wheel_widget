import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:async';
import 'spin_controller.dart';

class SpinItem {
  String label;
  TextStyle labelStyle;
  Color color;

  SpinItem(
      {required this.label, required this.color, required this.labelStyle});
}

class MySpinner extends StatefulWidget {
  final MySpinController mySpinController;
  final List<SpinItem> itemList;
  final double wheelSize;
  final Function(void) onFinished;
  final Function(String) onCurrentSegment;
  final double? tiltAngle;

  const MySpinner({
    Key? key,
    required this.mySpinController,
    required this.onFinished,
    required this.itemList,
    required this.wheelSize,
    required this.onCurrentSegment,
    this.tiltAngle,
  }) : super(key: key);

  @override
  State<MySpinner> createState() => _MySpinnerState();
}

class _MySpinnerState extends State<MySpinner> with TickerProviderStateMixin {
  double _lastRotation = 0;
  double _velocity = 0;
  Timer? _decelerationTimer;
  double _currentRotation = 0;
  double _lastSegmentAngle = 0;
  double _tiltAngle = 0;
  double _lastDividerPosition = 0;
  String? _lastLabel;

  void _updateCurrentSegment() {
    if (!mounted) return;

    final segmentAngle = 2 * math.pi / widget.itemList.length;
    double normalizedRotation = _currentRotation % (2 * math.pi);
    if (normalizedRotation < 0) normalizedRotation += 2 * math.pi;

    int currentSegment =
        ((2 * math.pi - normalizedRotation) / segmentAngle).floor();
    currentSegment = currentSegment % widget.itemList.length;

    final newLabel = widget.itemList[currentSegment].label;
    if (_lastLabel != newLabel) {
      _lastLabel = newLabel;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onCurrentSegment(newLabel);
        }
      });
    }
  }

  double _calculateSegmentAngle() {
    final normalizedRotation = _currentRotation % (2 * math.pi);
    final segmentAngle = 2 * math.pi / widget.itemList.length;
    return (normalizedRotation / segmentAngle).floor() * segmentAngle;
  }

  double _calculateDistanceToDivider() {
    final segmentAngle = 2 * math.pi / widget.itemList.length;
    final normalizedRotation = _currentRotation % (2 * math.pi);
    final currentSegment = (normalizedRotation / segmentAngle).floor();
    final nextDivider = (currentSegment + 1) * segmentAngle;
    final prevDivider = currentSegment * segmentAngle;

    final distanceToNext = (nextDivider - normalizedRotation).abs();
    final distanceToPrev = (normalizedRotation - prevDivider).abs();

    if (distanceToNext < distanceToPrev) {
      _lastDividerPosition = nextDivider;
      return distanceToNext;
    } else {
      _lastDividerPosition = prevDivider;
      return distanceToPrev;
    }
  }

  void _updateTiltBasedOnDivider() {
    final segmentAngle = 2 * math.pi / widget.itemList.length;
    final distanceToDivider = _calculateDistanceToDivider();

    final tiltRange = segmentAngle * 0.15;

    if (distanceToDivider < tiltRange) {
      final normalizedDistance = distanceToDivider / tiltRange;
      final tiltDirection = _velocity > 0 ? -1.0 : 1.0;
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
    widget.mySpinController.initLoad(
      tickerProvider: this,
      itemList: widget.itemList,
    );
    widget.mySpinController.setUpdateCallback((rotation) {
      setState(() {
        _currentRotation = rotation;
        _velocity = rotation - _lastRotation;
        _lastRotation = rotation;
        _updateTiltBasedOnDivider();
        _updateCurrentSegment();
      });
    });
    _lastSegmentAngle = _calculateSegmentAngle();
    _updateCurrentSegment();
  }

  void _handleDragStart(DragStartDetails details) {
    _decelerationTimer?.cancel();
    _lastRotation = _currentRotation;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _currentRotation += details.delta.dx * 0.01;
      _velocity = details.delta.dx * 0.01;
      _updateTiltBasedOnDivider();
      _updateCurrentSegment();
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    _decelerationTimer?.cancel();
    _decelerationTimer =
        Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _velocity *= 0.95;
        _currentRotation += _velocity;
        _updateTiltBasedOnDivider();
        _updateCurrentSegment();

        if (_velocity.abs() < 0.001) {
          timer.cancel();
          _tiltAngle = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _decelerationTimer?.cancel();
    if (widget.mySpinController.baseAnimation?.isAnimating == true) {
      widget.mySpinController.baseAnimation?.stop();
    }
    widget.mySpinController.baseAnimation?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Transform.rotate(
              angle: _currentRotation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Container(
                      width: widget.wheelSize,
                      height: widget.wheelSize,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: CustomPaint(
                        painter: SpinWheelPainter(items: widget.itemList),
                        child: Center(
                          child: Container(
                            width: widget.wheelSize * 0.18,
                            height: widget.wheelSize * 0.18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(widget.wheelSize * 0.02),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...widget.itemList.map((each) {
                    int index = widget.itemList.indexOf(each);
                    double rotateInterval = 360 / widget.itemList.length;
                    double rotateAmount = (index + 0.5) * rotateInterval;
                    return RotationTransition(
                      turns: AlwaysStoppedAnimation(rotateAmount / 360),
                      child: Transform.translate(
                        offset: Offset(0, -widget.wheelSize / 4),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(each.label, style: each.labelStyle),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            // Location icon with physics
            Transform.translate(
              offset: Offset(0, -widget.wheelSize * 0.019),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _tiltAngle * 1.7,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Blue glow
                        Container(
                          width: 30,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Blue marker
                        Icon(
                          Icons.location_on_sharp,
                          size: 50,
                          color: Colors.blue.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                  Transform.rotate(
                    angle: _tiltAngle,
                    child: const Icon(
                      Icons.location_on_sharp,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpinWheelPainter extends CustomPainter {
  final List<SpinItem> items;

  SpinWheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()..style = PaintingStyle.fill;
    final dividerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(0xFF00A0FF)
      ..strokeWidth = 1.5;

    // Create gradient for borders
    final Gradient borderGradient = SweepGradient(
      colors: [
        Colors.white,
        Colors.white.withOpacity(0.9),
        Color(0xFFE0B0FF).withOpacity(0.7), // Light purple
        Color(0xFFFFB0E0).withOpacity(0.7), // Light pink
        Colors.white.withOpacity(0.9),
        Colors.white,
      ],
      stops: [0.0, 0.3, 0.5, 0.7, 0.9, 1.0],
    );

    final totalSections = items.length;
    const totalAngle = 2 * math.pi;
    final sectionAngle = totalAngle / totalSections;

    // Draw alternating black and gradient gray segments
    for (var i = 0; i < items.length; i++) {
      final startAngle = i * sectionAngle;

      if (i % 2 == 0) {
        paint.color = Colors.black;
      } else {
        final rect = Rect.fromCircle(center: center, radius: radius);
        paint.shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF1A1A1A), // Darker gray at center
            Color(0xFF121212), // Even darker gray at middle
            Color(0xFF050505), // Almost black at edge
          ],
          stops: [0.3, 0.7, 1.0],
        ).createShader(rect);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Reset shader for next segment
      paint.shader = null;

      // Draw blue dividing lines
      final lineStartX = center.dx + (radius * 0.1) * math.cos(startAngle);
      final lineStartY = center.dy + (radius * 0.1) * math.sin(startAngle);
      final lineEndX = center.dx + radius * math.cos(startAngle);
      final lineEndY = center.dy + radius * math.sin(startAngle);

      canvas.drawLine(
        Offset(lineStartX, lineStartY),
        Offset(lineEndX, lineEndY),
        dividerPaint,
      );
    }

    // Draw outer circle with gradient
    final outerRect = Rect.fromCircle(center: center, radius: radius);
    final outerCirclePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..shader = borderGradient.createShader(outerRect);

    canvas.drawCircle(center, radius, outerCirclePaint);

    // Draw divider circles on top of everything
    for (var i = 0; i < items.length; i++) {
      final startAngle = i * sectionAngle;
      final dividerX = center.dx + radius * math.cos(startAngle);
      final dividerY = center.dy + radius * math.sin(startAngle);

      // Outer circle with gradient
      final dividerRect = Rect.fromCircle(
        center: Offset(dividerX, dividerY),
        radius: radius * 0.045,
      );

      final dividerGradientPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.9),
            Color(0xFFE0B0FF).withOpacity(0.7),
            Color(0xFFFFB0E0).withOpacity(0.7),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ).createShader(dividerRect);

      canvas.drawCircle(
        Offset(dividerX, dividerY),
        radius * 0.045,
        dividerGradientPaint,
      );

      // Inner circle for depth
      final innerDividerPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withOpacity(0.9);

      canvas.drawCircle(
        Offset(dividerX, dividerY),
        radius * 0.032,
        innerDividerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
