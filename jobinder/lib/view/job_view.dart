import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobinder/models/job_opportunities_model.dart';
import 'package:jobinder/templates/templates.dart';
import 'package:jobinder/view/new_job_form.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'homepage_employer.dart';
import '../models/job_opportunities_model.dart';
import '../providers/job_provider.dart';
import 'package:jobinder/view/job_details_view.dart';

class JobView extends StatelessWidget {
  const JobView({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Job Offers'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JobForm()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New job offer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<JobOpportunities>>(
              stream: jobProvider.jobs,
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
                        title: Text(job.jobName, textAlign: TextAlign.center),
                        subtitle: Text(
                          job.description,
                          textAlign: TextAlign.center,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _confirmDelete(context, job),
                        ),
                        onTap: () => _showDetails(context, job),
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
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, JobOpportunities job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailView(jobId: job.id)),
    );
  }

  void _confirmDelete(BuildContext context, JobOpportunities job) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this offer?'),
        content: Text(job.jobName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Provider.of<JobProvider>(
                context,
                listen: false,
              ).deleteJob(job.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
