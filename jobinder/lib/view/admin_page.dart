import 'package:flutter/material.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/templates/templates.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<AuthProvider>(context);
    final users = usersProvider.users;
    final isLoading = usersProvider.isLoading;

    /// Returns the icon corresponding to user's role
    Icon getUserIcon(String role) {
      switch (role) {
        case 'student':
          return const Icon(Icons.school);
        case 'employer':
          return const Icon(Icons.business);
        case 'admin':
          return const Icon(Icons.star);
        default:
          return const Icon(Icons.person);
      }
    }

    return UnauthenticatedTemplate(
      child: Scaffold(
        body: StreamBuilder<List<AppUser>>(
          stream: users,
          builder: (context, snapshot) {
            if (isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading users : ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return Center(child: Text('No users found.'));
            }

            return Column(
              children: [
                // Users
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, int index) {
                      final user = users[index];

                      return ListTile(
                        trailing: Text(user.id),
                        title: Text('${user.name} ${user.surname}'),
                        subtitle: Text('${user.email} | ${user.role}'),
                        leading: getUserIcon(user.role),
                      );
                    },
                  ),
                ),

                // Logout button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthProvider>().signOut();
                    },
                    child: Icon(Icons.logout),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
