import 'package:flutter/material.dart';
import 'package:jobinder/templates/templates.dart';
import 'package:provider/provider.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';

class JobView extends StatelessWidget {
  const JobView({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return UnauthenticatedTemplate(
      child: Scaffold(
        appBar: AppBar(title: const Text('Jobs')),
        body: Column(
          children: [
            // StreamBuilder<List<Job>>(
            //   stream: jobProvider.jobs,
            //   builder: (context, snapshot) {

            //     final jobs = snapshot.data ?? [];

            //     return ListView.builder(
            //       itemCount: jobs.length,
            //       itemBuilder: (context, index) {
            //         final job = jobs[index];
            //         return ListTile(
            //           leading: Text(job.name),
            //           title: Text(job.details),
            //         );
            //       },
            //     );
            //   },
            // ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Continuer'),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Profil'),
              ),
            )
          ],
        ),
      ),
    );
  }
}