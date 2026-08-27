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

  void _updateLanguageText() {
    final selected = <String>[];
    if (checkboxValue1) selected.add('French');
    if (checkboxValue2) selected.add('German');
    if (checkboxValue3) selected.add('Italian');
    if (checkboxValue4) selected.add('English');
    
    _languageController.text = selected.join(', ');
}

  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  bool checkboxValue4 = false;

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
                  textAlign: TextAlign.center,
                  _companyName ?? '...',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Theme.of(context).disabledColor),
                ),
              ),
            // Input job name
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

            // Input degree
            const SizedBox(height: 16),
            DropdownMenu<String>(
              initialSelection: _degreeController.text.isNotEmpty ? _degreeController.text : null,
              label: const Text('Degree'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Bachelor', label: 'Bachelor'),
                DropdownMenuEntry(value: 'Master', label: 'Master'),
                DropdownMenuEntry(value: 'PhD', label: 'PhD'),
              ],
              onSelected: (String? value) {
                if (value != null) {
                  setState(() {
                    _degreeController.text = value;
                  });
                }
              },
            ),

            // Input salary
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

            // Input languages
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('French'),
              value: checkboxValue1,
              onChanged: (bool? value) {
                setState(() {
                  checkboxValue1 = value ?? false;
                  _updateLanguageText();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('German'),
              value: checkboxValue2,
              onChanged: (bool? value) {
                setState(() {
                  checkboxValue2 = value ?? false;
                  _updateLanguageText();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Italian'),
              value: checkboxValue3,
              onChanged: (bool? value) {
                setState(() {
                  checkboxValue3 = value ?? false;
                  _updateLanguageText();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('English'),
              value: checkboxValue4,
              onChanged: (bool? value) {
                setState(() {
                  checkboxValue4 = value ?? false;
                  _updateLanguageText();
                });
              },
            ),

            // Input description
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

  // Save or update the job offer to firestore
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
