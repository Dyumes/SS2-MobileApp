import 'package:flutter/material.dart';
import 'package:jobinder/repositories/job_repository.dart';
import 'package:provider/provider.dart';
import '../models/job_opportunities_model.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../models/employer_model.dart';
import '../models/appuser_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jobinder/widgets/job_details_dialog.dart';

import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/firestore_job_repository.dart';

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

  final JobRepository _jobRepository = FirestoreJobRepository();
  final UserRepository _userRepository = FirestoreUserRepository();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Increment index to show the next job
  void _nextCard() {

    setState(() {
      _currentIndex++;
    });
  }

  void _applyCard(JobOpportunities job) {
    _jobRepository.updateStatus(
      job.id,
      context.read<AuthProvider>().user!.uid,
      'applied',
    );
    _nextCard();
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
            final matchesSearch = job.jobName.toLowerCase().contains(_searchQuery);
            final notApplied = !(job.studentApplication?.containsKey(context.read<AuthProvider>().user?.uid) ?? false) ;
            return matchesSearch && notApplied;
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
                          child: _buildJobCard(context, jobs[_currentIndex + 1], user.uid),
                        ),

                      _buildJobCard(context, currentJob, user.uid),
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
                      onPressed: () => showJobDetails(context, currentJob),
                      backgroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.info_outline, color: Colors.blue, size: 28),
                    ),

                    FloatingActionButton.large(
                      heroTag: 'like_btn',
                      onPressed: () => _applyCard(currentJob),
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

  Widget _buildJobCard(BuildContext context, JobOpportunities job, String studentUid) {
    return FutureBuilder(
      future: Future.wait([
        _userRepository.getEmployerByUid(job.employer_user),
        _userRepository.getUser(job.employer_user),
        _userRepository.getUser(studentUid),
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
        final userData = snapshot.data![1] as AppUser;
        final studentData = snapshot.data![2] as AppUser;

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              job.jobName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              job.degree,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.payments_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${job.salary} CHF',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' / hours',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (job.languages.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: job.languages.map((lang) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                lang,
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.business_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              job.industry,
                              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${userData.address}, ${employer.city} (${employer.canton})',
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              userData.email,
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
}