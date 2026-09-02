import 'package:flutter/material.dart';
import 'package:jobinder/widgets/salary_estimate_block.dart';
import '../models/job_opportunities_model.dart';
import '../models/employer_model.dart';
import '../models/appuser_model.dart';
import '../repositories/user_repository.dart';

class JobCard extends StatelessWidget {
  final JobOpportunities job;
  final String studentUid;
  final UserRepository userRepository;

  static const String _fixedImageUrl =
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab';

  const JobCard({
    super.key,
    required this.job,
    required this.studentUid,
    required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        userRepository.getEmployerByUid(job.employer_user),
        userRepository.getUser(job.employer_user),
        userRepository.getUser(studentUid),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          );
        }

        final employer = snapshot.data![0] as Employer;
        final userData = snapshot.data![1] as AppUser;

        return Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Image.network(
                  job.imageUrl ?? _fixedImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Job name + Degree
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    job.jobName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(51),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    job.degree,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 3),

                            // Company
                            Text(
                              employer.companyName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SalaryEstimateBlock(job: job, employer: employer),
                        const SizedBox(height: 12),
                        if (job.languages.isNotEmpty) ...[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: job.languages.map((lang) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withAlpha(51),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  lang,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const Divider(height: 1, color: Colors.white),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                job.industry,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${userData.address}, ${employer.city} (${employer.canton})',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                userData.email,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
