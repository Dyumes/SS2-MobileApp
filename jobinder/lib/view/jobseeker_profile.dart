import 'package:flutter/material.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/student_model.dart';
import '../models/appuser_model.dart';

class StudentProfileView extends StatelessWidget {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    // User is not logged in
    if (user == null) {
      return const Center(
        child: Text('No user logged in'),
      );
    }

    print(user.uid);

    final UserRepository userRepository = FirestoreUserRepository();

    return FutureBuilder(
      future: Future.wait([
        userRepository.getStudentByUid(user.uid),
        userRepository.getUser(user.uid),
      ]),
      builder: (context, snapshot) {
        print(snapshot);
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading profile:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        // No data
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No profile data found'),
          );
        }

        // Get the results from Future.wait()
        final jobseeker = snapshot.data![0] as Student;
        final userData = snapshot.data![1] as AppUser;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "${userData.name} ${userData.surname}",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            _InfoRow(
              label: 'Email',
              value: user.email ?? '',
            ),

            _InfoRow(
              label: 'History',
              value: jobseeker.history?.isNotEmpty == true
                  ? jobseeker.history!.first.company
                  : 'No history',
            ),

            _InfoRow(
              label: 'Address',
              value: userData.address,
            ),

            _InfoRow(
              label: 'Skills',
              value: jobseeker.skills?.join(', ') ?? 'No skills listed',
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthProvider>().signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Disconnect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}