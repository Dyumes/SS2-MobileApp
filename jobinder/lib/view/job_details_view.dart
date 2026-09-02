import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobinder/models/job_opportunities_model.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/models/student_model.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import 'package:jobinder/view/applicant_detail_view.dart';

class JobDetailView extends StatefulWidget {
  const JobDetailView({super.key, required this.jobId});
  final String jobId;

  @override
  State<JobDetailView> createState() => _JobDetailViewState();
}

class _JobDetailViewState extends State<JobDetailView> {
  final UserRepository _repo = FirestoreUserRepository();

  Future<List<({AppUser user, Student student, String status})>>
  _loadApplicants(JobOpportunities job) async {
    final entries = job.studentApplication.entries.toList();

    final results = await Future.wait(
      entries.map((e) async {
        final user = await _repo.getUser(e.key);
        final student = await _repo.getStudentByUid(e.key);
        if (user == null || student == null) return null;
        return (user: user, student: student, status: e.value);
      }),
    );

    return results
        .whereType<({AppUser user, Student student, String status})>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('job_opportunities')
          .doc(widget.jobId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Error: ${snap.error}')),
          );
        }
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This offer no longer exists')),
          );
        }

        final job = JobOpportunities.fromMap(snap.data!.data()!, snap.data!.id);
        final yearly = (42 * 4 * 12 * job.salary * job.workloadPercentage / 100)
            .round();

        return Scaffold(
          appBar: AppBar(
            title: Text(job.jobName),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (job.imageUrl != null && job.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    job.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _Row('Degree', job.degree),
              _Row('Description', job.description),
              _Row('Languages', job.languages.join(', ')),
              _Row('Hourly salary', '${job.salary} CHF'),
              _Row('Yearly salary', '$yearly CHF'),
              _Row('Workload', '${job.workloadPercentage}%'),
              _Row('Industry', job.industry),
              _Row(
                'Start date',
                DateFormat('yyyy-MM-dd').format(job.timestamp),
              ),
              _Row('Deadline', DateFormat('yyyy-MM-dd').format(job.deadline)),

              const SizedBox(height: 24),
              const Divider(),
              Text(
                'Applicants (${job.studentApplication.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              FutureBuilder<
                List<({AppUser user, Student student, String status})>
              >(
                future: _loadApplicants(job),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final applicants = snapshot.data ?? [];
                  if (applicants.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No applications yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: applicants.map((a) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                '${a.user.name.isNotEmpty ? a.user.name[0] : ''}'
                                '${a.user.surname.isNotEmpty ? a.user.surname[0] : ''}',
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ),
                            title: Text('${a.user.name} ${a.user.surname}'),
                            subtitle: Text(
                              a.student.skills?.join(', ') ?? 'No skills listed',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Chip(
                              label: Text(a.status),
                              backgroundColor: _statusColor(
                                a.status,
                              ).withAlpha(40),
                              labelStyle: TextStyle(
                                color: _statusColor(a.status),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ApplicantDetailView(
                                    job: job,
                                    user: a.user,
                                    student: a.student,
                                    currentStatus: a.status,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String status) => switch (status) {
    'accepted' => Colors.green,
    'refused' => Colors.red,
    _ => Colors.blue,
  };
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
