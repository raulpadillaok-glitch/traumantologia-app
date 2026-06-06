import 'package:flutter/material.dart';
import 'dart:ui';
import 'dashboard_screen.dart';
import 'catalog_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CatalogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to flow behind the bottom nav bar
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.greenAccent,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 14,
              unselectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.space_dashboard_rounded, size: 26)),
                  activeIcon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.space_dashboard_rounded, size: 30)),
                  label: 'Mi Progreso',
                ),
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.view_carousel_rounded, size: 26)),
                  activeIcon: Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.view_carousel_rounded, size: 30)),
                  label: 'Catálogo',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
