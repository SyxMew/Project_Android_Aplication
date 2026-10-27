import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavbar extends StatelessWidget {
  final int index;
  const BottomNavbar({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black.withAlpha(100),
      items: [
        BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              icon: const Icon(FontAwesomeIcons.house),
            ),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/menu');
              },
              icon: const Icon(FontAwesomeIcons.bookJournalWhills),
            ),
            label: 'Menu'),
        BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
              icon: const Icon(FontAwesomeIcons.solidUser),
            ),
            label: 'Profile'),
      ],
    );
  }
}
