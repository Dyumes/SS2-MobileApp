import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobinder/widgets/review_form.dart';
import 'package:jobinder/widgets/review_list.dart';
import 'package:provider/provider.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/models/student_model.dart';
import 'package:jobinder/models/job_opportunities_model.dart';
import 'package:jobinder/providers/job_provider.dart';

class ApplicantDetailView extends StatefulWidget {
  const ApplicantDetailView({
    super.key,
    required this.job,
    required this.user,
    required this.student,
    required this.currentStatus,
  });

  final JobOpportunities job;
  final AppUser user;
  final Student student;
  final String currentStatus;

  @override
  State<ApplicantDetailView> createState() => _ApplicantDetailViewState();
}

class _ApplicantDetailViewState extends State<ApplicantDetailView> {
  late String _status = widget.currentStatus;
  bool _saving = false;

  Future<void> _setStatus(String status) async {
    setState(() => _saving = true);

    await context.read<JobProvider>().updateStatus(
          widget.job.id,
          widget.user.id,
          status,
        );

    if (!mounted) return;
    setState(() {
      _status = status;
      _saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marked as $status')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final s = widget.student;

    return Scaffold(
      appBar: AppBar(
        title: Text('${u.name} ${u.surname}'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.orange.shade100,
              backgroundImage:
                  const AssetImage('images/placeholder_PROFILE.jpg'),
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: Chip(
              label: Text(_status),
              backgroundColor: _color(_status).withAlpha(38),
              labelStyle: TextStyle(
                color: _color(_status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          _Row('Email', u.email),
          _Row('Address', u.address),
          _Row('Degree', (s.degree?.isNotEmpty ?? false) ? s.degree! : 'Not specified'),
          _Row('Skills', s.skills?.join(', ') ?? 'No skills listed'),
          _Row('Min salary', s.minSalary != null ? '${s.minSalary} CHF' : 'Not specified'),
          _Row('Max distance', s.maxDistance != null ? '${s.maxDistance} km' : 'Not specified'),

          const SizedBox(height: 16),
          const Text('Work history',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          if (s.history == null || s.history!.isEmpty)
            const Text('No history', style: TextStyle(color: Colors.grey))
          else
            ...s.history!.map(
              (h) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.work_outline),
                title: Text(h.company),
                subtitle: Text(
                  '${h.link}\n${_range(h.startDate, h.endDate)}',
                ),
                isThreeLine: true,
              ),
            ),

          const SizedBox(height: 32),

          ReviewForm(revieweeId: widget.user.id),

          const SizedBox(height: 32),

          ReviewList(revieweeId: widget.user.id),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : () => _setStatus('refused'),
                  icon: const Icon(Icons.close),
                  label: const Text('Refuse'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => _setStatus('applied'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Pending'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : () => _setStatus('accepted'),
                  icon: const Icon(Icons.check),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _color(String s) => switch (s) {
        'accepted' => Colors.green,
        'refused' => Colors.red,
        _ => Colors.blue,
      };

  String _fmt(DateTime? d) =>
      d == null ? '?' : DateFormat('MM/yyyy').format(d);

  String _range(DateTime? a, DateTime? b) =>
      '${_fmt(a)} — ${b == null ? 'Present' : _fmt(b)}';
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}