import 'package:flutter/material.dart';
import 'package:jobinder/models/job_opportunities_model.dart';
import 'package:provider/provider.dart';
import 'package:jobinder/providers/job_provider.dart';

class ApplicationsList extends StatelessWidget {
  const ApplicationsList({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    // TODO JOBS BY STATUS
    final jobProvider = Provider.of<JobProvider>(context);
    //final List<String> jobs = jobProvider.studentjobs

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
    } else {
                          Expanded(
                  child: StreamBuilder<List<JobOpportunities>>(
                    stream: jobProvider.studentjobs,
                    builder: (context, snapshot) {
                      final jobs = snapshot.data ?? [];

                      return ScrollConfiguration(
                        behavior: ScrollConfiguration.of(
                          context,
                        ).copyWith(overscroll: false),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: jobs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            return ListTile(
                              leading: Text(job.degree),
                              title: Text(
                                job.jobName,
                                textAlign: TextAlign.center,
                              ),
                              subtitle: Text(
                                job.description,
                                textAlign: TextAlign.center,
                              ),
                              tileColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          },
                        ),
                      );
                    },
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