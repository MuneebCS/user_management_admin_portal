import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_management_admin_portal/screens/homepage.dart';
import 'package:user_management_admin_portal/widgets/custm_button.dart';
import '../providers/admin_authprovider.dart';
import 'login.dart';

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Are you sure you want to logout?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        text: "OK",
                        onPressed: () async {
                          await authProvider.logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                      ),
                      CustomButton(
                        text: "Cancel",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
