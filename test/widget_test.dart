import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_spinning_wheel/main.dart';
import 'package:flutter_spinning_wheel/widgets/my_spinning_wheel.dart';
import 'package:flutter_spinning_wheel/widgets/spin_controller.dart';
import 'package:flutter_spinning_wheel/pages/spin_reveal_page.dart';

void main() {
  testWidgets('MySpinner Widget Test', (WidgetTester tester) async {
    final spinController = MySpinController();
    final testItems = [
      SpinItem(
        label: 'Test 1',
        color: Colors.red,
        labelStyle: const TextStyle(color: Colors.white),
      ),
      SpinItem(
        label: 'Test 2',
        color: Colors.blue,
        labelStyle: const TextStyle(color: Colors.white),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MySpinner(
            mySpinController: spinController,
            wheelSize: 300.0,
            itemList: testItems,
            onCurrentSegment: (String label) {},
            onFinished: (void _) {},
          ),
        ),
      ),
    );

    expect(find.byType(MySpinner), findsOneWidget);
    expect(
      find.descendant(
        of: find.byWidgetPredicate((widget) =>
            widget is Container &&
            (widget.decoration as BoxDecoration?)?.shape == BoxShape.circle),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('SpinRevealPage Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SpinRevealPage(),
      ),
    );

    expect(find.byType(SpinRevealPage), findsOneWidget);
    expect(find.byType(MySpinner), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
