import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:jobinder/widgets/list_form_field.dart';

void main(){

testWidgets('ListFormField adds and removes items', (tester) async {
  List<String> result = [];

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ListFormField<String>(
        label: 'Skills',
        initialValue: const ['Dart'],
        onChanged: (items) => result = items,
        itemForm: (context, addItem) => ElevatedButton(
          onPressed: () => addItem('Flutter'),
          child: const Text('add'),
        ),
        itemBuilder: (context, s, remove) =>
            Chip(label: Text(s), onDeleted: remove),
      ),
    ),
  ));

  await tester.tap(find.text('add'));
  await tester.pump();

  expect(result, ['Dart', 'Flutter']);
});

}
