import 'package:flutter/material.dart';
import 'package:novelux/screen/explore/explore_screen.dart';
import 'package:novelux/screen/genres/genres_screen.dart';
import 'package:novelux/screen/library/library_screen.dart';
import 'package:novelux/screen/me/me_screen.dart';
import 'package:novelux/widgets/custom_buttom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
   int _currentIndex = 0;

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const LibraryScreen();
      case 1:
        return const ExploreScreen();
      case 2:
        return const GenresScreen();
      case 3:
        return const MeScreen();
      default:
        return const LibraryScreen(); 
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
        body: _getCurrentScreen(),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      );
  }
}