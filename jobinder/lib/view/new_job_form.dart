import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_opportunities_model.dart';
import '../providers/job_provider.dart';

class JobForm extends StatefulWidget {
  final JobOpportunities? job;

  const JobForm({super.key, this.job});

  @override
  JobFormState createState() => JobFormState();
}

class JobFormState extends State<JobForm> {
  final TextEditingController _jobNameController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  String? _companyName;

  final _formKey = GlobalKey<FormState>();

  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _degreeController.text = widget.job!.degree;
      _jobNameController.text = widget.job!.jobName;
      _descriptionController.text = widget.job!.description;
      _languageController.text = widget.job!.languages.join(', ');
      _salaryController.text = widget.job!.salary.toString();
    }
    _loadCompanyName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.job == null ? 'Create Job offer' : 'Edit Job')),
    body: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _companyName ?? '...',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Theme.of(context).disabledColor),
                ),
              ),
            TextFormField(
              controller: _jobNameController,
              decoration: const InputDecoration(labelText: 'Job\'s name'),
              maxLines: 1,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for the job';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _degreeController,
              decoration: const InputDecoration(labelText: 'Degree'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a degree';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _salaryController,
              decoration: const InputDecoration(labelText: 'Salary'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a salary';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _languageController,
              decoration: const InputDecoration(labelText: 'Languages (comma separated)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : () => _saveJob(context),
              child: Text(widget.job == null ? 'Save Job' : 'Update Job'),
            ),
          ],
        ),
      ),
    ),
    );
  }

  void _saveJob(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);

      if (widget.job == null) {
        jobProvider.addJob(JobOpportunities(
          employer_user: '',
          degree: _degreeController.text,
          jobName: _jobNameController.text,
          description: _descriptionController.text,
          languages: _languageController.text.split(',').map((e) => e.trim()).toList(),
          salary: int.tryParse(_salaryController.text) ?? 0,
        ));
      } else {
        jobProvider.updateJob(widget.job!.copyWith(
          employer_user: '',
          degree: _degreeController.text,
          jobName: _jobNameController.text,
          description: _descriptionController.text,
          languages: _languageController.text.split(',').map((e) => e.trim()).toList(),
          salary: int.tryParse(_salaryController.text) ?? 0,
        ));
      }
      Navigator.of(context).pop();
    }
  }

  void _loadCompanyName() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final name = await jobProvider.currentCompanyName();
    setState(() {
      _companyName = name;
    });
  }
}
