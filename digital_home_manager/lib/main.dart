import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth/auth_gate.dart';
import 'deadlines/deadlines_screen.dart';
import 'documents/documents_screen.dart';
import 'health/health_screen.dart';
import 'home_card/home_card_screen.dart';
import 'notifications/notification_service.dart';
import 'services/services_screen.dart';
import 'subscription/subscription_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  // The debug token must be copied from the log output when the app runs in debug provider mode.
  await NotificationService.initialize();
  runApp(const DigitalHomeManagerApp());
}

class DigitalHomeManagerApp extends StatelessWidget {
  const DigitalHomeManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Home Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthGate(
        child: MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeCardScreen(),
    DeadlinesScreen(),
    DocumentsScreen(),
    HealthScreen(),
    ServicesScreen(),
    SubscriptionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Deadlines'),
    BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Documents'),
    BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: 'Health'),
    BottomNavigationBarItem(icon: Icon(Icons.handyman), label: 'Services'),
    BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: 'Subscription'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_selectedIndex].label!),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
