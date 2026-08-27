import 'package:flutter/material.dart';

class UnauthenticatedTemplate extends StatelessWidget {
  const UnauthenticatedTemplate({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Logo
            const _AppLogo(),

            const SizedBox(height: 32),

            // Page content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthenticatedTemplate extends StatelessWidget {
  const AuthenticatedTemplate({
    required this.child,
    required this.currentIndex,
    required this.onNavigationChanged,
    super.key,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: _AppLogo(),
              ),
            ),

            const SizedBox(height: 16),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onNavigationChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'About',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'images/logo.png',
      width: 32,
      height: 32,
      fit: BoxFit.contain,
    );
  }
}

