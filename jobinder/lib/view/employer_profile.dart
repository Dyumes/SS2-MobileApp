import 'package:flutter/material.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import 'package:jobinder/utils/app_constants.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/employer_model.dart';
import '../models/appuser_model.dart';
import '../widgets/profile_edit_dialog.dart';

class EmployerProfileView extends StatefulWidget {
  const EmployerProfileView({super.key});

  @override
  State<EmployerProfileView> createState() => _EmployerProfileViewState();
}

class _EmployerProfileViewState extends State<EmployerProfileView> {
  final UserRepository _userRepository = FirestoreUserRepository();
  late Future<List<dynamic>> _future;
  String? _uid;

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
      _userRepository.getEmployerByUid(_uid!),
      _userRepository.getUser(_uid!),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading profile:\n${snapshot.error}',
                textAlign: TextAlign.center),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No profile data found'));
        }

        final employer = snapshot.data![0] as Employer;
        final userData = snapshot.data![1] as AppUser;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "${userData.name} ${userData.surname} / ${employer.companyName}",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _InfoRow(label: 'Email', value: user.email ?? ''),
            _InfoRow(label: 'Canton', value: employer.canton),
            _InfoRow(label: 'City', value: employer.city),
            _InfoRow(label: 'Address', value: userData.address),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final saved = await showEmployerEditDialog(
                  context,
                  employer: employer,
                  userData: userData,
                  userRepository: _userRepository,
                );
                if (saved == true) {
                  setState(_loadData);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
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
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

Future<bool?> showEmployerEditDialog(
  BuildContext context, {
  required Employer employer,
  required AppUser userData,
  required UserRepository userRepository,
}) {
  final cityController = TextEditingController(text: employer.city);
  final addressController = TextEditingController(text: userData.address);

  String? canton = employer.canton.isNotEmpty ? employer.canton : null;

  return showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => ProfileEditDialog(
        title: 'Edit profile',
        fields: [
          DropdownButtonFormField<String>(
            initialValue: canton,
            decoration: const InputDecoration(labelText: 'Canton'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFF222222),
            ),
            items: AppConstants.cantons
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => setDialogState(() => canton = value),
            validator: (v) => v == null ? 'Field required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: cityController,
            decoration: const InputDecoration(labelText: 'City'),
            validator: requiredValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(labelText: 'Address'),
            validator: requiredValidator,
          ),
        ],
        onSave: () async {
          await userRepository.updateEmployerProfile(
            employer.id,
            address: addressController.text.trim(),
            canton: canton ?? '',
            city: cityController.text.trim(),
          );
        },
      ),
    ),
  );
}