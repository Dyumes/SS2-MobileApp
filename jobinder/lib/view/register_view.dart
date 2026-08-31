import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/models/student_model.dart';
import 'package:jobinder/utils/app_constants.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/list_form_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends State<RegisterView> {
  // Controllers to manage input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole = _studentRole; // For ToggleButtons
  List<Skill> _skills = [];
  List<History> _companies = [];
  String? _selectedCanton;

  static const String _studentRole = "student";
  static const String _employerRole = "employer";

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Role selection
                Text('Choose a role', style: textTheme.labelLarge),
                Wrap(
                  spacing: 10.0,
                  children: [
                    ChoiceChip(
                      label: Text('Student'),
                      selected: _selectedRole == _studentRole,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedRole = _studentRole;
                          }
                        });
                      },
                    ),
                    ChoiceChip(
                      label: Text('Employer'),
                      selected: _selectedRole == "employer",
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedRole = _employerRole;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Global information",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                const SizedBox(height: 8),
          
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!regex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
          
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    final regex = RegExp(r'^[a-zA-Z .-]+$');
                    if (!regex.hasMatch(value)) {
                      return 'Please enter a valid name (no special chars aside from "-" and ".")';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
          
                // Surname
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Surname'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your surname';
                    }
                    final regex = RegExp(r'^[a-zA-Z .-]+$');
                    if (!regex.hasMatch(value)) {
                      return 'Please enter a valid surname (no special chars aside from "-" and ".")';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
          
                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
          
                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirm password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
          
                // Role-dependant fields
                if (_selectedRole == _studentRole) ...[
                  const SizedBox(height: 16),

                  // Surname
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Skills
                  ListFormField<Skill>(
                    label: 'Skills',
          
                    onChanged: (skills) {
                      _skills = skills;
                    },
          
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
                            addItem(Skill(controller.text.trim()));
                            controller.clear();
                          }
                        },
                      );
                    },
          
                    itemBuilder: (context, skill, remove) {
                      return Chip(
                        label: Text(skill.name),
                        onDeleted: remove,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
          
                  ListFormField<History>(
                    label: 'Work history',
          
                    onChanged: (companies) {
                      _companies = companies;
                    },
          
                    itemForm: (context, addItem) {
                      final nameController = TextEditingController();
                      final linkController = TextEditingController();
                      final startDateController = TextEditingController();
                      final endDateController = TextEditingController();
          
                      return Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Company name',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: linkController,
                            decoration: const InputDecoration(
                              labelText: 'Website',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: startDateController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Start date',
                                  ),
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
                                  decoration: const InputDecoration(
                                    labelText: 'End date',
                                  ),
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
          
                    itemBuilder: (context, company, remove) {
                      return ListTile(
                        title: Text(company.company),
                        subtitle: Text(company.link),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: remove,
                        ),
                      );
                    },
                  ),
                ],
          
                if (_selectedRole == _employerRole) ...[
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Company",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Name
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your company name';
                      }
                      final regex = RegExp(r'^[a-zA-Z .-]+$');
                      if (!regex.hasMatch(value)) {
                        return 'Please enter a valid name (no special chars aside from "-" and ".")';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Canton & City
                  Row(
                    children: [
                      DropdownMenu<String>(
                        label: const Text('Canton'),
                        dropdownMenuEntries: AppConstants.cantons
                          .map((c) => DropdownMenuEntry(value: c, label: c))
                          .toList(),
                        onSelected: (value) {
                          if (value != null) {
                            _selectedCanton = value;
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your company's city";
                            }
                            final regex = RegExp(r'^[a-zA-Z .-]+$');
                            if (!regex.hasMatch(value)) {
                              return 'Please enter a valid city (no special chars aside from "-" and ".")';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                ],
                
                const SizedBox(height: 40),
          
                // Register button
                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _authenticate(context),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text("Register"),
                ),
          
                // Return to login button
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () {
                          context.read<AuthProvider>().clearError();
                          Navigator.pop(
                            context,
                          ); // Navigate back to the previous screen
                        },
                  child: Text('Already have an account?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _authenticate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;
    final surname = _surnameController.text;
    final address = _addressController.text;
    final skills = _skills.map((s) => s.name).toList();
    final history = _companies;

    final companyName = _companyNameController.text;
    final canton = _selectedCanton;
    final city = _cityController.text;


    final navigator = Navigator.of(context);

    final success = switch (_selectedRole) {
      _studentRole => await authProvider.registerStudentWithEmailAndPassword(
          email,
          password,
          AppUser(name: name, surname: surname, address: address, email: email, role: "student"),
          Student(skills: skills, history: history)
        ),
      _employerRole => await authProvider.registerEmployerWithEmailAndPassword(
          email,
          password,
          AppUser(name: name, surname: surname, address: address, email: email, role: "employer"),
          Employer(companyName: companyName, canton: canton!, city: city)
        ),
      _ => false
    };

    
    if (success) {
      // Check if widget is still mounted before showing SnackBar
      if (!context.mounted) return;

      // Display toaster at the bottom of the screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account successfully created!")),
      );

      context.read<AuthProvider>().clearError();
      navigator.pop(); // Navigate back to the previous screen
    }
  }
}

class Skill {
  final String name;

  Skill(this.name);
}