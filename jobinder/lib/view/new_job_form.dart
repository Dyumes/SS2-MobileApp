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
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _jobNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isCompleted = false;
  String? _imageUrl;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.job == null ? 'New Job' : 'Edit Job')),
    body: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            const SizedBox(height: 16),
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

            CheckboxListTile(
              title: const Text('Completed'),
              value: _isCompleted,
              onChanged: (bool? value) {
                setState(() {
                  _isCompleted = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildImageSection(context),
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

  Widget _buildImageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _imageUrl!,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_uploadError != null) ...[
          Text(
            _uploadError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _saveJob(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);

      if (widget.job == null) {
        jobProvider.addJob(JobOpportunities(
          employer_user: "test",
          degree: _degreeController.text,
          jobName: _jobNameController.text,
          description: _descriptionController.text,
          languages: _languageController.text.split(',').map((e) => e.trim()).toList(),
          salary: int.tryParse(_salaryController.text) ?? 0,
        ));
      } else {
        jobProvider.updateJob(widget.job!.copyWith(
          employer_user: "test",
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
}
