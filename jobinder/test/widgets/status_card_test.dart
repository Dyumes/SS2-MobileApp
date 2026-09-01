import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:jobinder/widgets/status_card.dart';

void main(){

testWidgets('StatusCard shows the underline when selected', (tester) async {
  var tapped = false;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: StatusCard(
        label: 'Accepted',
        icon: Icons.check_circle,
        color: Colors.green,
        selected: true,
        onTap: () => tapped = true,
      ),
    ),
  ));

  expect(find.text('Accepted'), findsOneWidget);

  await tester.tap(find.byType(StatusCard));
  expect(tapped, isTrue);
});

}
