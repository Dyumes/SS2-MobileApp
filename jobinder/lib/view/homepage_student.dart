import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_opportunities_model.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../models/employer_model.dart';

import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import 'package:intl/intl.dart';

class HomePageStudent extends StatefulWidget {
  const HomePageStudent({super.key});

  @override
  State<HomePageStudent> createState() => _HomePageStudentState();
}

class _HomePageStudentState extends State<HomePageStudent> {
  static const String _fixedImageUrl = 'https://picsum.photos/600/400';
  int _currentIndex = 0;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final UserRepository _userRepository = FirestoreUserRepository();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Increment index to show the next job
  void _nextCard() {
    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(
        child: Text('No user logged in'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home Page'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                  _currentIndex = 0;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _currentIndex = 0;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      // Listen to the job opportunities stream
      body: StreamBuilder<List<JobOpportunities>>(
        stream: jobProvider.studentjobs,
        builder: (context, snapshot) {
          final allJobs = snapshot.data ?? [];

          // Filter job names
          final jobs = allJobs.where((job) {
            return job.jobName.toLowerCase().contains(_searchQuery);
          }).toList();

          if (jobs.isEmpty || _currentIndex >= jobs.length) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nothing', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          final currentJob = jobs[_currentIndex];
          // Card stack
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      if (_currentIndex + 1 < jobs.length)
                        Transform.scale(
                          scale: 1,
                          child: _buildJobCard(context, jobs[_currentIndex + 1]),
                        ),

                      _buildJobCard(context, currentJob),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton.large(
                      heroTag: 'dislike_btn',
                      onPressed: _nextCard,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.close, color: Colors.red, size: 36),
                    ),

                    FloatingActionButton(
                      heroTag: 'info_btn',
                      onPressed: () => _showJobDetails(context, currentJob),
                      backgroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.info_outline, color: Colors.blue, size: 28),
                    ),

                    FloatingActionButton.large(
                      heroTag: 'like_btn',
                      onPressed: _nextCard,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.favorite, color: Color.fromARGB(255, 255, 0, 0), size: 36),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobOpportunities job) {
    return FutureBuilder(
      future: Future.wait([
        _userRepository.getEmployerByUid(job.employer_user),
      ]),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Card(
            child: Center(
              child: Text('Error loading employer:\n${snapshot.error}'),
            ),
          );
        }

        // No data
        if (!snapshot.hasData || snapshot.data![0] == null) {
          return const Card(
            child: Center(child: Text('No employer data found')),
          );
        }

        final employer = snapshot.data![0] as Employer;

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
                  _fixedImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              job.jobName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Chip(label: Text(job.degree)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Hourly salary: ${job.salary} CHF'),
                      const SizedBox(height: 8),
                      Text(job.languages.join(', ')),
                      const SizedBox(height: 8),
                      Text('${employer.city}, ${employer.canton}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Job details pop up
  void _showJobDetails(BuildContext context, JobOpportunities job) {
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
                Text('Yearly salary : ${42 * 4 * 12 * job.salary * job.workloadPercentage / 100} CHF'),
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