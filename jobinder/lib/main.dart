import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/services/firebase_auth_service.dart';
import 'package:jobinder/view/login_view.dart';
import 'package:jobinder/utils/theme.dart';
import 'package:provider/provider.dart';

import 'utils/firebase_options.dart';
import 'repositories/firestore_job_repository.dart';
import 'providers/job_provider.dart';
import 'view/job_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => JobProvider(FirestoreJobRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(FirebaseAuthService()),
        ),

      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Jobinder',
            theme: buildThemeData(),
            // Page changes automatically when user authenticates or logs out
            home: auth.user != null ? const JobView() : const LoginView(), // Show the login view initially
          );
        },
      ),
    );
  }
}