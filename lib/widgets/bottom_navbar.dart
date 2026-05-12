import 'package:flutter/material.dart';

import '../utils/theme.dart';

class BottomNavbar extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(

      currentIndex: currentIndex,
      onTap: onTap,

      backgroundColor: AppColors.card,

      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,

      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Notifications",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}