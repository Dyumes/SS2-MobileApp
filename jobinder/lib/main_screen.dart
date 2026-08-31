import 'package:flutter/material.dart';
import 'package:jobinder/templates/templates.dart';
import 'package:jobinder/view/job_view.dart';
import 'package:jobinder/view/homepage_student.dart';
import 'package:jobinder/view/employer_profile.dart';
import 'package:jobinder/view/jobseeker_profile.dart';
import 'package:jobinder/services/firebase_auth_service.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 1;

  String? role;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final uid = context.read<AuthProvider>().user?.uid;    
    print(uid);
    if (uid != null) {
      final user = await FirestoreUserRepository().getUser(uid);
      role = user.role;
      print('User role: $role');
    }
    if (mounted) setState(() => loading = false);
  }

  Widget get firstPage {
    if (role == 'student') return const HomePageStudent();
    if (role == 'employer') return const JobView();
    print("Role is null or unrecognized, defaulting to JobView");
    return const JobView(); 
  }

  Widget get middlePage {
    if (role == 'student') return const HomePageStudent();
    if (role == 'employer') return const JobView();
    print("Role is null or unrecognized, defaulting to JobView");
    return const JobView(); 
  }

  Widget get finalPage {
    if (role == 'student') return const StudentProfileView();
    if (role == 'employer') return const EmployerProfileView();
    print("Role is null or unrecognized, defaulting to JobView");
    return const JobView(); 
  }

  List<Widget> get pages => [
        firstPage,
        middlePage,
        finalPage,
      ];

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AuthenticatedTemplate(
      currentIndex: currentIndex,
      onNavigationChanged: (index) {
        setState(() => currentIndex = index);
      },
      child: pages[currentIndex],
    );
  }
}