import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/my_spinning_wheel.dart';
import '../widgets/spin_controller.dart';

class WheelPage extends StatefulWidget {
  const WheelPage({super.key});

  @override
  WheelPageState createState() => WheelPageState();
}

class WheelPageState extends State<WheelPage> {
  StreamController<int> selected = StreamController<int>();
  final double wheelSize = 450.0;
  final ValueNotifier<String> currentLabel = ValueNotifier<String>('');

  @override
  void dispose() {
    selected.close();
    currentLabel.dispose();
    super.dispose();
  }

  MySpinController mySpinController = MySpinController();

  void _updateCurrentLabel(String label) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentLabel.value = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xff0C1B3A)),
        child: Stack(
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
            // Centered current element text
            Center(
              child: ValueListenableBuilder<String>(
                valueListenable: currentLabel,
                builder: (context, value, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      value,
                      key: ValueKey<String>(value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Wheel at bottom
            Positioned(
              bottom: -wheelSize / 2,
              left: 0,
              right: 0,
              child: MySpinner(
                key: const ValueKey('spinner'),
                mySpinController: mySpinController,
                wheelSize: wheelSize,
                onCurrentSegment: _updateCurrentLabel,
                itemList: [
                  SpinItem(
                      label: '0% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '5% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '10% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '15% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '20% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '25% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '30% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '35% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '40% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '45% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '50% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '55% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '60% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                  SpinItem(
                      label: '65% Sale',
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      color: Colors.black),
                ],
                onFinished: (p0) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
