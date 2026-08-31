import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import 'package:jobinder/utils/app_constants.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/student_model.dart';
import '../models/appuser_model.dart';
import '../widgets/profile_edit_dialog.dart';
import '../widgets/list_form_field.dart';
import '../widgets/status_card.dart';
import '../widgets/application_student.dart';

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({super.key});

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  final UserRepository _userRepository = FirestoreUserRepository();
  late Future<List<dynamic>> _future;
  String? _uid;
  String _selectedStatus = 'submitted';

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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    return FutureBuilder<List<dynamic>>(
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

            const SizedBox(height: 16),

            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange.shade100,
                backgroundImage: const AssetImage('images/placeholder_PROFILE.jpg'),
              ),
            ),

            const SizedBox(height: 24),

            _InfoRow(label: 'Email', value: user.email ?? ''),
            _InfoRow(
              label: 'History',
              value: jobseeker.history?.map((item) => item.company).join(", ") ?? 'No history',
            ),
            _InfoRow(label: 'Address', value: userData.address),
            _InfoRow(
              label: 'Skills',
              value: jobseeker.skills?.join(', ') ?? 'No skills listed',
            ),
            _InfoRow(
              label: 'Degree',
              value: (jobseeker.degree?.isNotEmpty ?? false)
                  ? jobseeker.degree!
                  : 'Not specified',
            ),
            _InfoRow(
              label: 'Min salary',
              value: jobseeker.minSalary != null
                  ? '${jobseeker.minSalary} CHF'
                  : 'Not specified',
            ),
            _InfoRow(
              label: 'Max distance',
              value: jobseeker.maxDistance != null
                  ? '${jobseeker.maxDistance} km'
                  : 'Not specified',
            ),

            const SizedBox(height: 32),

            Center(
              child: FractionallySizedBox(
                widthFactor: 0.6,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final saved = await showStudentEditDialog(
                      context,
                      student: jobseeker,
                      userData: userData,
                      userRepository: _userRepository,
                    );
                    if (saved == true) {
                      setState(_loadData);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'My applications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: StatusCard(
                    label: 'Submitted',
                    icon: Icons.pending,
                    color: Colors.blue,
                    selected: _selectedStatus == 'submitted',
                    onTap: () => setState(() => _selectedStatus = 'submitted'),
                  ),
                ),
                Expanded(
                  child: StatusCard(
                    label: 'Accepted',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    selected: _selectedStatus == 'accepted',
                    onTap: () => setState(() => _selectedStatus = 'accepted'),
                  ),
                ),
                Expanded(
                  child: StatusCard(
                    label: 'Refused',
                    icon: Icons.cancel,
                    color: Colors.red,
                    selected: _selectedStatus == 'refused',
                    onTap: () => setState(() => _selectedStatus = 'refused'),
                  ),
                ),
              ],
            ),

            const Divider(height: 1),

            ApplicationsList(status: _selectedStatus),

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
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// --- Inchangé par rapport à ta v2 : le dialogue d'édition avec tes widgets ---
Future<bool?> showStudentEditDialog(
  BuildContext context, {
  required Student student,
  required AppUser userData,
  required UserRepository userRepository,
}) {
  final addressController = TextEditingController(text: userData.address);
  final minSalaryController = TextEditingController(text: student.minSalary?.toString() ?? '');
  final maxDistanceController = TextEditingController(text: student.maxDistance?.toString() ?? '');

  List<String> skills = List.from(student.skills ?? []);
  List<History> history = List.from(student.history ?? []);
  String? degree = (student.degree?.isNotEmpty ?? false) ? student.degree : null;

  return showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => ProfileEditDialog(
        title: 'Edit profile',
        fields: [
          SizedBox(height: 5),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(labelText: 'Address'),
            validator: requiredValidator,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: degree,
            decoration: const InputDecoration(labelText: 'Degree'),
            hint: const Text('No diploma'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFF222222),
            ),
            items: AppConstants.degrees
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (value) => setDialogState(() => degree = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: minSalaryController,
            decoration: const InputDecoration(labelText: 'Minimum Salary (CHF)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: maxDistanceController,
            decoration: const InputDecoration(labelText: 'Max Distance (km)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ListFormField<String>(
            label: 'Skills',
            initialValue: skills,
            onChanged: (items) => skills = items,
            itemForm: (context, addItem) {
              final controller = TextEditingController();
              return TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Skill',
                  suffixIcon: Icon(Icons.add),
                ),
                onFieldSubmitted: (_) {
                  if (controller.text.trim().isNotEmpty) {
                    addItem(controller.text.trim());
                    controller.clear();
                  }
                },
              );
            },
            itemBuilder: (context, skill, remove) => Chip(
              label: Text(skill),
              onDeleted: remove,
            ),
          ),
          const SizedBox(height: 16),
          ListFormField<History>(
            label: 'Work history',
            initialValue: history,
            onChanged: (items) => history = items,
            itemForm: (context, addItem) {
              final nameController = TextEditingController();
              final linkController = TextEditingController();
              final startDateController = TextEditingController();
              final endDateController = TextEditingController();

              return Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Company name'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: linkController,
                    decoration: const InputDecoration(labelText: 'Website'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: startDateController,
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Start date'),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              startDateController.text =
                                  '${date.day.toString().padLeft(2, '0')}/'
                                  '${date.month.toString().padLeft(2, '0')}/'
                                  '${date.year}';
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: endDateController,
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'End date'),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              endDateController.text =
                                  '${date.day.toString().padLeft(2, '0')}/'
                                  '${date.month.toString().padLeft(2, '0')}/'
                                  '${date.year}';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) return;
                          addItem(
                            History(
                              company: nameController.text.trim(),
                              link: linkController.text.trim(),
                              startDate: startDateController.text.isNotEmpty
                                  ? DateFormat('dd/MM/yyyy').parse(startDateController.text)
                                  : null,
                              endDate: endDateController.text.isNotEmpty
                                  ? DateFormat('dd/MM/yyyy').parse(endDateController.text)
                                  : null,
                            ),
                          );
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ),
                ],
              );
            },
            itemBuilder: (context, company, remove) => ListTile(
              title: Text(company.company),
              subtitle: Text(company.link),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: remove,
              ),
            ),
          ),
        ],
        onSave: () async {
          await userRepository.updateStudentProfile(
            student.id,
            address: addressController.text.trim(),
            skills: skills,
            history: history,
            degree: degree,
            minSalary: int.tryParse(minSalaryController.text.trim()),
            maxDistance: int.tryParse(maxDistanceController.text.trim()),
          );
        },
      ),
    ),
  );
}