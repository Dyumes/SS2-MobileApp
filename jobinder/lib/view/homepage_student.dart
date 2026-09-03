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
import '../widgets/swipeable_card.dart';

class HomePageStudent extends StatefulWidget {
  const HomePageStudent({super.key, this.jobRepository, this.userRepository});

  final JobRepository? jobRepository;
  final UserRepository? userRepository;

  @override
  State<HomePageStudent> createState() => _HomePageStudentState();
}

class _HomePageStudentState extends State<HomePageStudent> {
  // Ids of the offers already handled in this session, liked or skipped.
  // A Set instead of an index: the list of offers shrinks under us every time
  // Firestore pushes an update, so any position we stored would drift and end
  // up past the end of the list, showing "Nothing" while offers remain.
  final Set<String> _handled = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _uid;
  Future<List<dynamic>>? _future;
  final GlobalKey<SwipeableCardState> _cardKey = GlobalKey();

  late final JobRepository _jobRepository =
      widget.jobRepository ?? FirestoreJobRepository();
  late final UserRepository _userRepository =
      widget.userRepository ?? FirestoreUserRepository();

  // clear the search query
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // Skip the current offer: it stays in Firestore, we just stop showing it
  void _skipCard(JobOpportunities job) {
    setState(() => _handled.add(job.id));
  }

  // Apply for a job
  Future<void> _applyCard(JobOpportunities job) async {
    final messenger = ScaffoldMessenger.of(context);
    final uid = context.read<AuthProvider>().user!.uid;

    // Hide the card straight away, without waiting for Firestore to echo back
    setState(() => _handled.add(job.id));

    try {
      await _jobRepository.updateStatus(job.id, uid, 'applied');
    } catch (e) {
      // The write failed, so put the offer back in the deck
      if (mounted) setState(() => _handled.remove(job.id));
      messenger.showSnackBar(SnackBar(content: Text('Could not apply: $e')));
    }
  }

  // Show job details in a dialog
  void _showJobDetails(
    BuildContext context,
    JobOpportunities job,
    String studentUid,
  ) {
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
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading offers: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // Without this the first frame has no data yet and shows
              // "Nothing" for a moment every time the page is rebuilt
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allJobs = snapshot.data ?? [];

              final jobs = allJobs.where((job) {
                final matchesSearch = job.jobName.toLowerCase().contains(
                  _searchQuery,
                );
                final notApplied = !(job.studentApplication.containsKey(
                  user.uid,
                ));
                final notHandled = !_handled.contains(job.id);

                // Filter jobs
                final matchesDegree = (student.degree?.isEmpty ?? true) || student.degree == 'All' || job.degree == student.degree ;
                final matchesSalary = student.minSalary == null || job.salary >= student.minSalary!;
                final matchesIndustry = (student.industry?.isEmpty ?? true) || student.industry == 'All' || job.industry == student.industry ;


                return matchesSearch && notApplied && notHandled && matchesDegree && matchesSalary && matchesIndustry;
              }).toList();

              if (jobs.isEmpty) {
                return const Center(
                  child: Text('Nothing', style: TextStyle(fontSize: 18)),
                );
              }

              // Always the head of the list: no index to keep in sync
              final currentJob = jobs.first;

              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Stack(
                        children: [
                          // Card underneath, drawn first so it stays behind
                          if (jobs.length > 1)
                            JobCard(
                              key: ValueKey(jobs[1].id),
                              job: jobs[1],
                              studentUid: user.uid,
                              userRepository: _userRepository,
                            ),
                          SwipeableCard(
                            key: _cardKey,
                            onSwipeLeft: () => _skipCard(currentJob),
                            onSwipeRight: () => _applyCard(currentJob),
                            child: JobCard(
                              key: ValueKey(currentJob.id),
                              job: currentJob,
                              studentUid: user.uid,
                              userRepository: _userRepository,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton.large(
                          heroTag: 'dislike_btn',
                          onPressed: () => _cardKey.currentState?.swipe(false),
                          backgroundColor: Colors.white,
                          elevation: 4,
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                        FloatingActionButton.large(
                          heroTag: 'info_btn',
                          onPressed: () =>
                              _showJobDetails(context, currentJob, user.uid),
                          backgroundColor: Colors.white,
                          elevation: 4,
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 36,
                          ),
                        ),
                        FloatingActionButton.large(
                          heroTag: 'like_btn',
                          onPressed: () => _cardKey.currentState?.swipe(true),
                          backgroundColor: Colors.white,
                          elevation: 4,
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 36,
                          ),
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