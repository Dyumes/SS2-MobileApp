import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_opportunities_model.dart';
import '../providers/job_provider.dart';

class HomePageStudent extends StatefulWidget {
  const HomePageStudent({super.key});

  @override
  State<HomePageStudent> createState() => _HomePageStudentState();
}

class _HomePageStudentState extends State<HomePageStudent> {
  static const String _fixedImageUrl = 'https://picsum.photos/600/400';
  int _currentIndex = 0;

  void _nextCard() {
    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home Page'),
      ),
      body: StreamBuilder<List<JobOpportunities>>(
        stream: jobProvider.jobs,
        builder: (context, snapshot) {
          final jobs = snapshot.data ?? [];

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

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      if (_currentIndex + 1 < jobs.length)
                        Transform.scale(
                          scale: 0.95,
                          child: _buildJobCard(context, jobs[_currentIndex + 1]),
                        ),

                      _buildJobCard(context, currentJob),
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
            flex: 3,
            child: Image.network(
              _fixedImageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                  Text('${job.salary} CHF'),
                  const SizedBox(height: 8),
                  Text(job.languages.join(', ')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                Text('Salary : ${job.salary} CHF'),
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