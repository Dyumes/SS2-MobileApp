import 'package:flutter/material.dart';
import 'package:jobinder/models/job_opportunities_model.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:provider/provider.dart';
import 'package:jobinder/providers/job_provider.dart';
import 'package:jobinder/widgets/job_details_dialog.dart';
import 'package:jobinder/providers/auth_provider.dart';

class ApplicationsList extends StatelessWidget {
  const ApplicationsList({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    final studentUid = context.watch<AuthProvider>().user?.uid;

    if (studentUid == null) {
      return const Center(child: Text('You are not logged in'));
    }

    return StreamBuilder<List<JobOpportunities>>(
      stream: jobProvider.studentjobs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading jobs: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final jobs = snapshot.data ?? [];

        // Filter jobs based on the current student's application status
        final filteredJobs = jobs.where((job) {
          return job.studentApplication[studentUid] == status;
        }).toList();

        if (filteredJobs.isEmpty) {
          return Center(
            child: Text(
              'No $status applications',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: filteredJobs.map((job) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 1,
              clipBehavior:
                  Clip.antiAlias, // pour que le ripple respecte les coins
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => JobDetailsDialog(
                    job: job,
                    studentUid: studentUid,
                    userRepository: FirestoreUserRepository(),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Job icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.work_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Job information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.jobName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              job.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 6),

                            Text(
                              '${job.salary} CHF',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Indicates that the item can be opened
                      Icon(Icons.chevron_right, color: Colors.grey[500]),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
