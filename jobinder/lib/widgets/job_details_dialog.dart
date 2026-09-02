import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobinder/widgets/salary_estimate_block.dart';
import '../models/job_opportunities_model.dart';
import '../models/appuser_model.dart';
import '../models/employer_model.dart';
import '../models/transport.dart';
import '../repositories/user_repository.dart';
import '../services/transport_service.dart';

class JobDetailsDialog extends StatelessWidget {
  final JobOpportunities job;
  final String studentUid;
  final UserRepository userRepository;

  const JobDetailsDialog({
    super.key,
    required this.job,
    required this.studentUid,
    required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.from(alpha: 1, red: 1, green: 0.97, blue: 0.98),
      title: Text(job.jobName),
      content: SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait([
            userRepository.getUser(studentUid),
            userRepository.getEmployerByUid(job.employer_user),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Error loading user information.');
            }

            final studentUser = snapshot.data![0] as AppUser;
            final employerUser = snapshot.data![1] as Employer;

            return ListBody(
              children: [
                Text('Degree : ${job.degree}'),
                // const SizedBox(height: 8),
                // Text('Hourly salary : ${job.salary} CHF'),
                // const SizedBox(height: 8),
                // Text('Yearly salary : ${(42 * 4 * 12 * job.salary * job.workloadPercentage / 100).toStringAsFixed(2)} CHF'),
                const SizedBox(height: 8),
                SalaryEstimateBlock(job: job, employer: employerUser),
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
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 5, child: Text('Journey', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 2, child: Text('Platform', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.black38),
                const SizedBox(height: 8),

                FutureBuilder<List<Transport>>(
                  future: TransportService.fetchTransports(studentUser.address, employerUser.city),
                  builder: (context, transportSnapshot) {
                    if (transportSnapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Loading connections...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      );
                    }
                    if (transportSnapshot.hasError || !transportSnapshot.hasData || transportSnapshot.data!.isEmpty) {
                      return const Text('No connections found.', style: TextStyle(color: Colors.red, fontSize: 12));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: transportSnapshot.data!.map((transport) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...transport.sections.map((section) {
                              final stepDep = TransportService.formatTime(section["departureTime"] ?? '');
                              final stepArr = TransportService.formatTime(section["arrivalTime"] ?? '');
                              final transportCode = section["type"] ?? 'Transit';
                              final platformDep = section["departurePlatform"] ?? '';
                              final platformArr = section["arrivalPlatform"] ?? '';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 3, child: Text(stepDep, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                        Expanded(flex: 5, child: Text(section["departureStation"] ?? '', style: const TextStyle(fontSize: 12))),
                                        Expanded(flex: 2, child: Text(platformDep, style: const TextStyle(fontSize: 11, color: Colors.black54), textAlign: TextAlign.right)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      children: [
                                        const Expanded(flex: 3, child: SizedBox()),
                                        Expanded(flex: 5, child: Text(transportCode, style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold))),
                                        const Expanded(flex: 2, child: SizedBox()),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 3, child: Text(stepArr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                        Expanded(flex: 5, child: Text(section["arrivalStation"] ?? '', style: const TextStyle(fontSize: 12))),
                                        Expanded(flex: 2, child: Text(platformArr, style: const TextStyle(fontSize: 11, color: Colors.black54), textAlign: TextAlign.right)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              );
                            }).toList(),
                            const Divider(height: 16, color: Colors.black26),
                          ],
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

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
}