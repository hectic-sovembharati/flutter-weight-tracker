import 'package:flutter/material.dart';
import 'package:weight_tracker/Pages/profile.dart';
import 'Pages/home.dart';
import 'Pages/stats.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    Statsist(),
    Profile_Page(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF667EEA),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0 
                    ? const Color(0xFF667EEA).withOpacity(0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home,
                  size: 24,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1 
                    ? const Color(0xFF667EEA).withOpacity(0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bar_chart,
                  size: 24,
                ),
              ),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2 
                    ? const Color(0xFF667EEA).withOpacity(0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  size: 24,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}