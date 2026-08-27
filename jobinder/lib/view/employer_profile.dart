import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employer_provider.dart';
import '../providers/auth_provider.dart';

class EmployerProfileView extends StatelessWidget {
  const EmployerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final employer = context.watch<EmployerProvider>().employer;
    final email = context.watch<AuthProvider>().user?.email ?? '';
    final address = context.watch<EmployerProvider>().user?.adress ?? '';

    if (employer == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          employer.entrepriseName,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        _InfoRow(label: 'Email', value: email),
        _InfoRow(label: 'Canton', value: employer.canton),
        _InfoRow(label: 'City', value: employer.city),
        _InfoRow(label: 'Address', value: address),

        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => context.read<AuthProvider>().signOut(),
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
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}