import 'package:flutter/material.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';

class JobView extends StatelessWidget {
  const JobView({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Job>>(
              stream: jobProvider.jobs,
              builder: (context, snapshot) {
                final jobs = snapshot.data ?? [];
    
                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return ListTile(
                      leading: Text(job.name),
                      title: Text(job.details),
                    );
                  },
                );
              },
            ),
          ),
    
          // Log out button
          ElevatedButton(
            onPressed: () => authProvider.signOut(),
            child: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
