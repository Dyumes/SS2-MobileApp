import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_opportunities_model.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../repositories/job_repository.dart';
import '../repositories/user_repository.dart';
import 'package:jobinder/widgets/job_details_dialog.dart';
import '../repositories/firestore_job_repository.dart';
import '../repositories/firestore_user_repository.dart';
import '../widgets/job_card.dart';
import '../models/student_model.dart';

class HomePageStudent extends StatefulWidget {
  const HomePageStudent({super.key});

  @override
  State<HomePageStudent> createState() => _HomePageStudentState();
}

class _HomePageStudentState extends State<HomePageStudent> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _uid;
  Future<List<dynamic>>? _future;

  final JobRepository _jobRepository = FirestoreJobRepository();
  final UserRepository _userRepository = FirestoreUserRepository();

  // clear the search query
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Move to the next card
  void _nextCard() {
    setState(() {
      _currentIndex++;
    });
  }

  // Load student and user data 
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.watch<AuthProvider>().user;
    if (user != null && user.uid != _uid) {
      _uid = user.uid;
      _loadData();
    }
  }

  void _loadData() {
    _future = Future.wait([
      _userRepository.getStudentByUid(_uid!),
      _userRepository.getUser(_uid!),
    ]);
  }

  // Apply for a job
  void _applyCard(JobOpportunities job) {
    _jobRepository.updateStatus(
      job.id,
      context.read<AuthProvider>().user!.uid,
      'applied',
    );
    _nextCard();
  }

  // Show job details in a dialog
  void _showJobDetails(BuildContext context, JobOpportunities job, String studentUid) {
    showDialog(
      context: context,
      builder: (_) => JobDetailsDialog(
        job: job,
        studentUid: studentUid,
        userRepository: _userRepository,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: Text('No user logged in'));
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

      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, studentSnapshot) {
          if (studentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (studentSnapshot.hasError || !studentSnapshot.hasData) {
            return const Center(child: Text('Error loading student profile'));
          }

          final student = studentSnapshot.data![0] as Student;

          return StreamBuilder<List<JobOpportunities>>(
            stream: jobProvider.studentjobs,
            builder: (context, snapshot) {
              final allJobs = snapshot.data ?? [];

              final jobs = allJobs.where((job) {
                final matchesSearch = job.jobName.toLowerCase().contains(_searchQuery);
                final notApplied = !(job.studentApplication.containsKey(user.uid));

                // Filter jobs 
                final matchesDegree = (student.degree?.isEmpty ?? true) || job.degree == student.degree;
                final matchesSalary = student.minSalary == null || job.salary >= student.minSalary!;

                // final matchesDistance

                return matchesSearch && notApplied && matchesDegree && matchesSalary;
              }).toList();

              if (jobs.isEmpty || _currentIndex >= jobs.length) {
                return const Center(child: Text('Nothing', style: TextStyle(fontSize: 18)));
              }

              final currentJob = jobs[_currentIndex];

              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          if (_currentIndex + 1 < jobs.length)
                            JobCard(
                              job: jobs[_currentIndex + 1],
                              studentUid: user.uid,
                              userRepository: _userRepository,
                            ),
                          JobCard(
                            job: currentJob,
                            studentUid: user.uid,
                            userRepository: _userRepository,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                          onPressed: () => _showJobDetails(context, currentJob, user.uid),
                          backgroundColor: Colors.white,
                          elevation: 4,
                          child: const Icon(Icons.info_outline, color: Colors.blue, size: 28),
                        ),
                        FloatingActionButton.large(
                          heroTag: 'like_btn',
                          onPressed: () => _applyCard(currentJob),
                          backgroundColor: Colors.white,
                          elevation: 4,
                          child: const Icon(Icons.favorite, color: Colors.red, size: 36),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}