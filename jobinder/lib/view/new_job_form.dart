import 'package:flutter/material.dart';
import 'package:jobinder/services/salary_predictor.dart';
import 'package:jobinder/utils/app_constants.dart';
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
  final TextEditingController _workloadPercentageController =
      TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _timestampController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _contractController = TextEditingController();
  final TextEditingController _companySizeController = TextEditingController();
  final TextEditingController _holidaysController = TextEditingController();

  String? _companyName;
  String? _companyCanton;
  double? _prediction;

  double? get _yearlyFullTime {
    final hourly = int.tryParse(_salaryController.text);
    return hourly == null ? null : hourly * 42 * 4 * 12.0;
  }

  int? get _workload => int.tryParse(_workloadPercentageController.text);

  double? get _yearlyAtWorkload {
    final full = _yearlyFullTime;
    final w = _workload;
    return (full == null || w == null) ? null : full * w / 100;
  }

  double? get _predictionAtWorkload {
    final w = _workload;
    return (_prediction == null || w == null) ? null : _prediction! * w / 100;
  }

  final _formKey = GlobalKey<FormState>();

  final bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _degreeController.text = widget.job!.degree;
      _jobNameController.text = widget.job!.jobName;
      _descriptionController.text = widget.job!.description;
      _languageController.text = widget.job!.languages.join(', ');
      _salaryController.text = widget.job!.salary.toString();
      _workloadPercentageController.text = widget.job!.workloadPercentage
          .toString();
      _industryController.text = widget.job!.industry;
      _timestampController.text = widget.job!.timestamp.toString();
      _deadlineController.text = widget.job!.deadline.toString();
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

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime initialDate =
        DateTime.tryParse(_deadlineController.text) ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _deadlineController.text = pickedDate.toIso8601String().split('T')[0];
      });
    }
  }

  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  bool checkboxValue4 = false;

  @override
  Widget build(BuildContext context) {
    print(
      'role=${_roleController.text} | contract=${_contractController.text} | '
      'size=${_companySizeController.text} | industry=${_industryController.text} | '
      'degree=${_degreeController.text} | holidays=${_holidaysController.text} | '
      'canton=$_companyCanton | canPredict=$_canPredict',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job == null ? 'Create Job offer' : 'Edit Job'),
      ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
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
                initialSelection: _degreeController.text.isNotEmpty
                    ? _degreeController.text
                    : null,
                hintText: "No diploma",
                label: const Text('Degree'),
                dropdownMenuEntries: AppConstants.degrees
                    .map((d) => DropdownMenuEntry(value: d, label: d))
                    .toList(),
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

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salaryController,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Salary (CHF)',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter a salary';
                        if (int.tryParse(value) == null)
                          return 'Please enter a valid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _yearlyFullTime == null
                                ? 'Full time: -'
                                : 'Full time: ${_yearlyFullTime!.round()} CHF/year',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            _yearlyAtWorkload == null
                                ? 'At workload: -'
                                : 'At workload: ${_yearlyAtWorkload!.round()} CHF/year',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      child: FilledButton.icon(
                        onPressed: _canPredict ? _predict : null,
                        icon: const Icon(Icons.auto_graph),
                        label: const Text('Estimate'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: _prediction == null
                          ? Text(
                              'Fill role, contract, size, industry, degree and holidays',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Market: ${_prediction!.round()} CHF/year (full time)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_predictionAtWorkload != null)
                                  Text(
                                    'Market: ${_predictionAtWorkload!.round()} CHF/year (at ${_workload}%)',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),

                                if (_yearlyFullTime != null)
                                  Text(
                                    _yearlyFullTime! >= _prediction!
                                        ? '${((_yearlyFullTime! / _prediction! - 1) * 100).round()}% above market'
                                        : '${((1 - _yearlyFullTime! / _prediction!) * 100).round()}% below market',
                                    style: TextStyle(
                                      color: _yearlyFullTime! >= _prediction!
                                          ? Colors.green.shade700
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _workloadPercentageController,
                decoration: const InputDecoration(
                  labelText: 'Workload Percentage (%)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workload percentage';
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null || intValue < 0 || intValue > 100) {
                    return 'Please enter a valid percentage between 0 and 100';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Languages',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('French'),
                    selected: checkboxValue1,
                    onSelected: (v) => setState(() {
                      checkboxValue1 = v;
                      _updateLanguageText();
                    }),
                  ),
                  FilterChip(
                    label: const Text('German'),
                    selected: checkboxValue2,
                    onSelected: (v) => setState(() {
                      checkboxValue2 = v;
                      _updateLanguageText();
                    }),
                  ),
                  FilterChip(
                    label: const Text('Italian'),
                    selected: checkboxValue3,
                    onSelected: (v) => setState(() {
                      checkboxValue3 = v;
                      _updateLanguageText();
                    }),
                  ),
                  FilterChip(
                    label: const Text('English'),
                    selected: checkboxValue4,
                    onSelected: (v) => setState(() {
                      checkboxValue4 = v;
                      _updateLanguageText();
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownMenu<String>(
                      expandedInsets: EdgeInsets.zero,
                      initialSelection: _industryController.text.isNotEmpty
                          ? _industryController.text
                          : null,
                      label: const Text('Industry'),
                      dropdownMenuEntries: AppConstants.industries
                          .map((i) => DropdownMenuEntry(value: i, label: i))
                          .toList(),
                      onSelected: (String? value) {
                        if (value != null) {
                          setState(() {
                            _industryController.text = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownMenu<String>(
                      expandedInsets: EdgeInsets.zero,
                      initialSelection: _roleController.text.isNotEmpty
                          ? _roleController.text
                          : null,
                      label: const Text('Seniority level'),
                      dropdownMenuEntries: AppConstants.roles
                          .map((r) => DropdownMenuEntry(value: r, label: r))
                          .toList(),
                      onSelected: (String? value) {
                        if (value != null)
                          setState(() => _roleController.text = value);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: DropdownMenu<String>(
                      expandedInsets: EdgeInsets.zero,
                      initialSelection: _contractController.text.isNotEmpty
                          ? _contractController.text
                          : null,
                      label: const Text('Contract duration'),
                      dropdownMenuEntries: AppConstants.contracts
                          .map((c) => DropdownMenuEntry(value: c, label: c))
                          .toList(),
                      onSelected: (String? value) {
                        if (value != null)
                          setState(() => _contractController.text = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownMenu<String>(
                      expandedInsets: EdgeInsets.zero,
                      initialSelection: _companySizeController.text.isNotEmpty
                          ? _companySizeController.text
                          : null,
                      label: const Text('Company size'),
                      dropdownMenuEntries: AppConstants.companySizes
                          .map((s) => DropdownMenuEntry(value: s, label: s))
                          .toList(),
                      onSelected: (String? value) {
                        if (value != null)
                          setState(() => _companySizeController.text = value);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _holidaysController,
                decoration: const InputDecoration(
                  labelText: 'Holidays per year (days)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final days = int.tryParse(value ?? '');
                  if (days == null || days < 20 || days > 40) {
                    return 'Please enter a number between 20 and 40';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

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

              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Deadline',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDeadline(context),
                  ),
                ),
                onTap: () => _selectDeadline(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a deadline';
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
        jobProvider.addJob(
          JobOpportunities(
            employer_user: '',
            degree: _degreeController.text,
            jobName: _jobNameController.text,
            description: _descriptionController.text,
            languages: _languageController.text
                .split(',')
                .map((e) => e.trim())
                .toList(),
            salary: int.tryParse(_salaryController.text) ?? 0,
            workloadPercentage:
                int.tryParse(_workloadPercentageController.text) ?? 0,
            industry: _industryController.text,
            deadline:
                DateTime.tryParse(_deadlineController.text) ?? DateTime.now(),
            timestamp: DateTime.now(),
            role: _roleController.text,
            contract: _contractController.text,
            holidays: int.tryParse(_holidaysController.text) ?? 25,
          ),
        );
      } else {
        jobProvider.updateJob(
          widget.job!.copyWith(
            employer_user: '',
            degree: _degreeController.text,
            jobName: _jobNameController.text,
            description: _descriptionController.text,
            languages: _languageController.text
                .split(',')
                .map((e) => e.trim())
                .toList(),
            salary: int.tryParse(_salaryController.text) ?? 0,
            workloadPercentage:
                int.tryParse(_workloadPercentageController.text) ?? 0,
            industry: _industryController.text,
            deadline:
                DateTime.tryParse(_deadlineController.text) ?? DateTime.now(),
            timestamp: DateTime.now(),
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }

  void _loadCompanyName() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final name = await jobProvider.currentCompanyName();
    final canton = await jobProvider.currentCompanyCanton();
    setState(() {
      _companyName = name;
      _companyCanton = canton;
    });
  }

  bool get _canPredict =>
      _roleController.text.isNotEmpty &&
      _contractController.text.isNotEmpty &&
      _companySizeController.text.isNotEmpty &&
      _industryController.text.isNotEmpty &&
      _degreeController.text.isNotEmpty &&
      (int.tryParse(_holidaysController.text) ?? 0) >= 20 &&
      (_companyCanton ?? '').isNotEmpty;

  Future<void> _predict() async {
    final predictor = await SalaryPredictor.load();
    final value = predictor.predictForJob(
      role: _roleController.text,
      contract: _contractController.text,
      industry: _industryController.text,
      canton: _companyCanton!,
      companySize: _companySizeController.text,
      degree: _degreeController.text,
      languages: _languageController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
      holidays: int.parse(_holidaysController.text),
    );
    setState(() => _prediction = value);
  }
}
