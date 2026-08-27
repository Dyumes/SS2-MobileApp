import 'package:flutter/material.dart';
import 'package:jobinder/templates/templates.dart';
import 'package:jobinder/view/job_view.dart';
import 'package:jobinder/view/login_view.dart';
import 'package:jobinder/view/employer_profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 1;

  final pages = const [
    JobView(),
    JobView(),
    EmployerProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthenticatedTemplate(
      currentIndex: currentIndex,
      onNavigationChanged: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      child: pages[currentIndex],

    );
  }
}