import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      ],
      child: MaterialApp(
        title: 'Jobinder',
        theme: buildThemeData(),
        home: const JobView(),
      ),
    );
  }
}