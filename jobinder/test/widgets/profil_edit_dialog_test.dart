import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/widgets/profile_edit_dialog.dart';

void main() {
  /// Opens [ProfileEditDialog] from a real route so `Navigator.pop` behaves
  /// like it does in the app.
  Future<void> openDialog(
    WidgetTester tester, {
    required List<Widget> fields,
    required Future<void> Function() onSave,
    required void Function(bool?) onClosed,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) => ProfileEditDialog(
                    title: 'Edit profile',
                    fields: fields,
                    onSave: onSave,
                  ),
                );
                onClosed(result);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('an invalid field blocks the save', (tester) async {
    var saveCalled = false;

    await openDialog(
      tester,
      fields: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Address'),
          validator: requiredValidator,
        ),
      ],
      onSave: () async => saveCalled = true,
      onClosed: (_) {},
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Field required'), findsOneWidget);
    expect(saveCalled, isFalse);
    expect(find.byType(ProfileEditDialog), findsOneWidget);
  });

  testWidgets('a valid form saves and closes with true', (tester) async {
    var saveCalled = false;
    bool? result;

    await openDialog(
      tester,
      fields: [
        TextFormField(
          initialValue: 'Sion',
          decoration: const InputDecoration(labelText: 'Address'),
          validator: requiredValidator,
        ),
      ],
      onSave: () async => saveCalled = true,
      onClosed: (value) => result = value,
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    expect(saveCalled, isTrue);
    expect(result, isTrue);
    expect(find.byType(ProfileEditDialog), findsNothing);
  });

  testWidgets('cancelling closes with false without saving', (tester) async {
    var saveCalled = false;
    bool? result;

    await openDialog(
      tester,
      fields: const [Text('nothing to fill')],
      onSave: () async => saveCalled = true,
      onClosed: (value) => result = value,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(saveCalled, isFalse);
    expect(result, isFalse);
  });

  testWidgets('a failing save shows the error and keeps the dialog open',
      (tester) async {
    await openDialog(
      tester,
      fields: const [Text('nothing to fill')],
      onSave: () async => throw Exception('network down'),
      onClosed: (_) {},
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Error occured while saving'), findsOneWidget);
    expect(find.byType(ProfileEditDialog), findsOneWidget);
  });

  testWidgets('both buttons are disabled while saving', (tester) async {
    final gate = Completer<void>();

    await openDialog(
      tester,
      fields: const [Text('nothing to fill')],
      onSave: () => gate.future,
      onClosed: (_) {},
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );

    gate.complete();
    await tester.pumpAndSettle();
  });
}