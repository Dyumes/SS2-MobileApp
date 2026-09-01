import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jobinder/main_screen.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/services/firebase_auth_service.dart';
import 'package:jobinder/view/admin_page.dart';
import 'package:jobinder/view/login_view.dart';
import 'package:jobinder/utils/theme.dart';
import 'package:provider/provider.dart';

import 'utils/firebase_options.dart';
import 'repositories/firestore_job_repository.dart';
import 'providers/job_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Text(
        'Erreur : ${details.exceptionAsString()}',
        style: const TextStyle(color: Colors.red, fontSize: 10),
      ),
    );
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(FirebaseAuthService()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, JobProvider>(
          create: (_) => JobProvider(FirestoreJobRepository()),
          update: (_, auth, jobProvider) => jobProvider!..updateAuth(auth),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Jobinder',
            theme: buildThemeData(),
            home: () {
              if (auth.user == null) {
                return const LoginView();
              } else {
                if (auth.appUser != null && auth.appUser?.role == 'admin') {
                  return const AdminPage();
                } else {
                  return const MainScreen();
                }
              }
            }(),
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              overscroll: false,
            ),
          );
        },
      ),
    );
  }
}
