import 'package:flutter/material.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:jobinder/widgets/status_card.dart';
import 'package:jobinder/widgets/application_student.dart';

import '../providers/auth_provider.dart';
import '../models/student_model.dart';
import '../models/appuser_model.dart';

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({super.key});

  @override 
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  final UserRepository _userRepository = FirestoreUserRepository();
  Future<List<dynamic>>? _future;
  String? _uid;
  String _selectedStatus = 'submitted';

  void _loadData(String uid) {
    _future = Future.wait([
      _userRepository.getStudentByUid(uid),
      _userRepository.getUser(uid),
    ]);
  }

Future<void> _openEditDialog(Student student) async {
  final result = await showDialog<({List<String> skills, List<History> history})>(
    context: context,
    builder: (_) => _EditStudentDialog(student: student),
  );
  if (result == null) return;
  await _userRepository.updateStudentProfile(
    _uid!,
    skills: result.skills,
    history: result.history,
  );
  if (!mounted) return;
  setState(() => _loadData(_uid!));
}

void _openApplications(String status) {
  print("Opening applications with status: $status");
}

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    // (re)construit le future seulement si l'uid change
    if (_uid != user.uid) {
      _uid = user.uid;
      _loadData(user.uid);
    }

    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading profile:\n${snapshot.error}'));
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

            Center(
              child: FractionallySizedBox(
                widthFactor: 0.4,   // 70% de la largeur disponible
                child: ElevatedButton.icon(
                  onPressed: () => _openEditDialog(jobseeker),
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

            const SizedBox(height: 32),

            const Text(
              'My applications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

class _AddHistoryDialog extends StatefulWidget {
  const _AddHistoryDialog();

  @override
  State<_AddHistoryDialog> createState() => _AddHistoryDialogState();
}

class _AddHistoryDialogState extends State<_AddHistoryDialog> {
  final _company = TextEditingController();
  final _link = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _company.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _start : _end) ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => isStart ? _start = picked : _end = picked);
  }

  String _fmt(DateTime? d) =>
      d == null ? 'Not set' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New experience'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _company,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            TextField(
              controller: _link,
              decoration: const InputDecoration(labelText: 'Link'),
            ),

            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Start: ${_fmt(_start)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('End: ${_fmt(_end)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_company.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              History(
                company: _company.text.trim(),
                link: _link.text.trim(),
                startDate: _start,
                endDate: _end,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _EditStudentDialog extends StatefulWidget {
  const _EditStudentDialog({required this.student});
  final Student student;

  @override
  State<_EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<_EditStudentDialog> {
  late List<String> _skills;
  late List<History> _history;   // remplace par le vrai type de ta liste
  final _skillController = TextEditingController();

  // Helper methods to format dates for display
  String _fmtDate(DateTime? d) =>
    d == null ? '?' : '${d.month}/${d.year}';

  String _fmtRange(DateTime? start, DateTime? end) =>
    '${_fmtDate(start)} — ${end == null ? 'Present' : _fmtDate(end)}';


  @override
  void initState() {
    super.initState();
    _skills = List<String>.from(widget.student.skills ?? []);
    _history = List<History>.from(widget.student.history ?? []);
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final value = _skillController.text.trim();
    if (value.isEmpty || _skills.contains(value)) return;
    setState(() => _skills.add(value));
    _skillController.clear();
  }

  Future<void> _addHistory() async {
    final entry = await showDialog<History>(
      context: context,
      builder: (_) => const _AddHistoryDialog(),
    );
    if (entry != null) setState(() => _history.add(entry));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit profile'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Skills', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _skills
                    .map((s) => Chip(
                          label: Text(s),
                          onDeleted: () => setState(() => _skills.remove(s)),
                        ))
                    .toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillController,
                      decoration: const InputDecoration(hintText: 'New skill'),
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addSkill),
                ],
              ),

              const SizedBox(height: 24),
              const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._history.map(
                (h) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(h.company),
                  subtitle: Text(
                    '${h.link}\n${_fmtRange(h.startDate, h.endDate)}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _history.remove(h)),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addHistory,
                icon: const Icon(Icons.add),
                label: const Text('Add experience'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            (skills: _skills, history: _history),  
          ),
          child: const Text('Save'),
        ),
      ],
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