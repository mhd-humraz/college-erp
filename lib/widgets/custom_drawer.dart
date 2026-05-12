import 'package:flutter/material.dart';

import '../utils/theme.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    return Drawer(

      backgroundColor: AppColors.background,

      child: ListView(
        children: [

          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.card,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [

                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 15),

                Text(
                  "College ERP",

                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          drawerItem(
            icon: Icons.dashboard,
            title: "Dashboard",
          ),

          drawerItem(
            icon: Icons.person,
            title: "Profile",
          ),

          drawerItem(
            icon: Icons.notifications,
            title: "Notifications",
          ),

          drawerItem(
            icon: Icons.logout,
            title: "Logout",
          ),
        ],
      ),
    );
  }

  Widget drawerItem({
    required IconData icon,
    required String title,
  }) {

    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),

      title: Text(
        title,

        style: const TextStyle(
          color: AppColors.text,
        ),
      ),

      onTap: () {},
    );
  }
}