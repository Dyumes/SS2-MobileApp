import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends State<RegisterView> {
  // Controllers to manage input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole; // For ToggleButtons

  final String _studentRole = "student";
  final String _employerRole = "employer";

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        _selectedRole = selected ? _studentRole : null;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: Text('Employer'),
                    selected: _selectedRole == "employer",
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedRole = selected ? _employerRole : null;
                      });
                    },
                  ),
                ],
              ),

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
              const SizedBox(height: 20),

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
    );
  }

  void _authenticate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text;
    final password = _passwordController.text;

    final navigator = Navigator.of(context);

    final success = await authProvider.registerWithEmailAndPassword(
      email,
      password,
    );

    if (success) {
      // Check if widget is still mounted before showing SnackBar
      if (!context.mounted) return;

      // Display toaster at the bottom of the screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account successfully created!")),
      );
      navigator.pop(); // Navigate back to the previous screen
    }
  }
}
