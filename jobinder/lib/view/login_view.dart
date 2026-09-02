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
  final FaceRecognitionService _faceService = FaceRecognitionService();
  bool _isProcessingFace = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

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
              if (authProvider.errorMessage != null) ...[
                Text(
                  authProvider.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 10),
              ],
                ElevatedButton.icon(
                  onPressed: (authProvider.isLoading || _isProcessingFace)
                      ? null
                      : () => _captureAndCompareFace(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: _isProcessingFace
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.face),
                  label: const Text('Autofill Email with Face ID'),
                ),
              
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : () => _authenticate(context),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Login'),
              ),

              TextButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () {
                        context.read<AuthProvider>().clearError();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterView()),
                        );
                      },
                child: Text("Don't have an account?"),
              ),
            ],
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