import 'package:flutter/material.dart';
import 'package:user_management_admin_portal/screens/all_user_view.dart';
import 'package:user_management_admin_portal/screens/new_user.dart';
import 'package:user_management_admin_portal/widgets/custm_button.dart';

import 'logout.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: [
          Center(
            child: Text(
              "Welcome Admin",
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 28, // Slightly smaller for balance
                fontWeight: FontWeight.w600, // Medium weight for readability
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: CustomButton(
                    text: "Add New User",
                    onPressed: () {
                      _pageController.jumpToPage(0);
                    },
                  ),
                ),
                const SizedBox(width: 8), // Spacing between buttons
                Flexible(
                  child: CustomButton(
                    text: "View all Users",
                    onPressed: () {
                      _pageController.jumpToPage(1);
                    },
                  ),
                ),
                const SizedBox(width: 8), // Spacing between buttons
                Flexible(
                  child: CustomButton(
                    text: "Logout",
                    onPressed: () {
                      _pageController.jumpToPage(2);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                NewUser(),
                UsersListScreen(),
                LogoutPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutPage() {
    return const Center(
      child: Text(
        'Logout Page',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
