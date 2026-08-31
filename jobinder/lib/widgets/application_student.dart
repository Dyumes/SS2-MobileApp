import 'package:flutter/material.dart';

class ApplicationsList extends StatelessWidget {
  const ApplicationsList({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    // TODO JOBS BY STATUS
    final List<String> jobs = [];

    if (jobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No $status applications',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: jobs
          .map((j) => ListTile(
                leading: const Icon(Icons.work_outline),
                title: Text(j),
              ))
          .toList(),
    );
  }
}