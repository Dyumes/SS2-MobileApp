import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobinder/models/job_opportunities_model.dart';

void showJobDetails(BuildContext context, JobOpportunities job) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(job.jobName),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Degree : ${job.degree}'),
              const SizedBox(height: 8),
              Text('Hourly salary : ${job.salary} CHF'),
              const SizedBox(height: 8),
              Text('Yearly salary : ${(42 * 4 * 12 * job.salary * job.workloadPercentage / 100).round()} CHF'),
              const SizedBox(height: 8),
              Text('Workload : ${job.workloadPercentage}%'),
              const SizedBox(height: 8),
              Text('Industry : ${job.industry}'),
              const SizedBox(height: 8),
              Text('Start date : ${DateFormat('yyyy-MM-dd').format(job.timestamp)}'),
              const SizedBox(height: 8),
              Text('Deadline : ${DateFormat('yyyy-MM-dd').format(job.deadline)}'),
              const SizedBox(height: 8),
              Text('Description : ${job.description}'),
              const SizedBox(height: 8),
              Text('Languages : ${job.languages.join(', ')}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}