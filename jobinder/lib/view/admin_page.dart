import 'package:flutter/material.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/services/seed_service.dart';
import 'package:jobinder/templates/templates.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  /// Returns the icon corresponding to the user's role
  Icon _getUserIcon(String role) {
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

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
    String successMessage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

    Future<bool> _confirm(BuildContext context, String message) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return answer ?? false;
  }


  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<AuthProvider>(context);
    final users = usersProvider.users;
    final isLoading = usersProvider.isLoading;

    return UnauthenticatedTemplate(
      child: Scaffold(
        body: StreamBuilder<List<AppUser>>(
          stream: users,
          builder: (context, snapshot) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading users : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return const Center(child: Text('No users found.'));
            }

            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, int index) {
                final user = list[index];

                return ListTile(
                  trailing: Text(user.id),
                  title: Text('${user.name} ${user.surname}'),
                  subtitle: Text('${user.email} | ${user.role}'),
                  leading: _getUserIcon(user.role),
                );
              },
            );
          },
        ),

        // Wrap instead of Row: it sizes itself without needing a bounded
        // width, which the surrounding template does not provide.
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                IconButton.filled(
                  onPressed: () =>
                      _run(context, SeedService.seed, 'Database seeded'),
                  icon: const Icon(Icons.cloud_upload),
                  tooltip: 'Seed database',
                ),
                IconButton.filled(
                  onPressed: () =>
                      _run(context, SeedService.clear, 'Seed data removed'),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear seed data',
                ),
                                IconButton.filled(
                  onPressed: () async {
                    final confirmed = await _confirm(
                      context,
                      'This deletes every non-admin user, generated or not, '
                      'with their profile and their job offers. Admins are '
                      'kept. Auth accounts survive except for seeded users.',
                    );
                    if (!confirmed) return;
                    if (!context.mounted) return;
                    await _run(
                      context,
                      SeedService.clearAll,
                      'All non-admin users removed',
                    );
                  },
                  icon: const Icon(Icons.delete_forever),
                  tooltip: 'Delete all non-admin users',
                ),
                IconButton.filled(
                  onPressed: () => context.read<AuthProvider>().signOut(),
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign out',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
