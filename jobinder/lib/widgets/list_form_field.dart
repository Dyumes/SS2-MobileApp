import 'package:flutter/material.dart';

class ListFormField<T> extends StatefulWidget {
  final String label;
  final List<T> initialValue;
  final Widget Function(
    BuildContext context,
    void Function(T item) addItem,
  ) itemForm;
  final Widget Function(
    BuildContext context,
    T item,
    VoidCallback removeItem,
  ) itemBuilder;
  final ValueChanged<List<T>> onChanged;

  const ListFormField({
    super.key,
    required this.label,
    this.initialValue = const [],
    required this.itemForm,
    required this.itemBuilder,
    required this.onChanged,
  });

  @override
  State<ListFormField<T>> createState() => _ListFormFieldState<T>();
}

class _ListFormFieldState<T> extends State<ListFormField<T>> {
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialValue);
  }

  void _addItem(T item) {
    setState(() {
      _items.add(item);
    });

    widget.onChanged(_items);
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });

    widget.onChanged(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return widget.itemBuilder(
              context,
              item,
              () => _removeItem(index),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        widget.itemForm(context, _addItem),
      ],
    );
  }
}