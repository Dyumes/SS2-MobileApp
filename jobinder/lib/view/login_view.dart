import 'package:flutter/material.dart';
import 'package:jobinder/view/register_view.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'dart:typed_data';
import '../view/camera_view.dart';
import '../services/face_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  // Controllers to manage input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  final FaceRecognitionService _faceService = FaceRecognitionService();
  bool _isProcessingFace = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              // keeps the form readable on wide screens instead of
              // stretching every field edge to edge
              constraints: const BoxConstraints(maxWidth: 380),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'images/logo_nobg.png',
                      height: 120,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.work_outline,
                        size: 96,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jobinder',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
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

                    if (authProvider.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        authProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],

                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _authenticate(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),

                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _captureAndCompareFace(context),
                      icon: const Icon(Icons.face_retouching_natural),
                      label: const Text('Face ID Login'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              context.read<AuthProvider>().clearError();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterView()),
                              );
                            },
                      child: const Text("Don't have an account?"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _captureAndCompareFace(BuildContext context) async {
    final Uint8List? bytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => const CameraView()),
    );

    if (bytes == null) return;

    setState(() => _isProcessingFace = true);

    try {
      final faces = await _faceService.detectFaces(bytes);
      if (faces.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No face detected. Please try again.')),
        );
        return;
      }

      final currentVector =
          await _faceService.recognizeFace(bytes, faces.first);
      if (currentVector.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to extract face features.')),
        );
        return;
      }

      final provider = Provider.of<AuthProvider>(context, listen: false);
      final matchedEmail = await provider.findUserEmailByFaceVector(
        currentVector,
        _faceService,
      );

      if (matchedEmail != null) {
        if (!mounted) return;

        setState(() {
          _emailController.text = matchedEmail;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User recognized! Email set to $matchedEmail'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Face not recognized. No matching account found.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Face ID Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessingFace = false);
    }
  }

  void _authenticate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text;
    final password = _passwordController.text;

    await provider.signInWithEmailAndPassword(email, password);
  }

}