import 'package:Snapdrop/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppBackground renders its child', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppBackground(child: Text('hello')),
      ),
    );

    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('AppBackground paints the locked base fill #142C1D',
      (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppBackground(child: SizedBox.shrink()),
      ),
    );

    final coloredBox = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(AppBackground),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(coloredBox.color, const Color(0xFF142C1D));
  });
}
