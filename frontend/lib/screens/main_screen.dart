import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/employer_home_screen.dart';
import 'package:frontend/screens/favorites_screen.dart';
import 'package:frontend/screens/job_seeker_home_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isJobSeeker = authProvider.role == 'job_seeker';

    final List<Widget> _jobSeekerPages = <Widget>[
      const JobSeekerHomeScreen(),
      const FavoritesScreen(),
      const ProfileScreen(), // This will show the current user's profile
      const SettingsScreen(),
    ];

    final List<Widget> _employerPages = <Widget>[
      const EmployerHomeScreen(),
      const ProfileScreen(), // This will show the current user's profile
      const SettingsScreen(),
    ];

    final List<BottomNavigationBarItem> _jobSeekerNavItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ];

    final List<BottomNavigationBarItem> _employerNavItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ];


    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      body: Center(
        child: isJobSeeker ? _jobSeekerPages.elementAt(_selectedIndex) : _employerPages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: isJobSeeker ? _jobSeekerNavItems : _employerNavItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
