import 'package:flutter/material.dart';
import 'package:user_management_admin_portal/screens/user_detail.dart';
import 'package:user_management_admin_portal/widgets/custm_button.dart';
import '../models/user.dart';

class CustomCard extends StatelessWidget {
  final User user;

  CustomCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  child: user.profileImageUrl.isNotEmpty
                      ? null
                      : Icon(Icons.person,
                          size: 30, color: Theme.of(context).primaryColor),
                ),
                if (user.profileImageUrl.isNotEmpty)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                user.fullName,
                style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CustomButton(
              text: "...",
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailScreen(user: user),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
