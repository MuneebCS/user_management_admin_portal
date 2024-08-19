import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/admin_authprovider.dart';
import '../widgets/custom_card.dart';

class UsersListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Users List'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: authProvider.viewAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No users found.'));
              }

              List<User> users = snapshot.data!.map((data) {
                return User(
                  uid: data['uid'] ?? 'unknown',
                  email: data['email'] as String? ?? 'No Email',
                  fullName: data['fullName'] as String? ?? 'No Name',
                  profileImageUrl: data['profileImageUrl'] as String? ?? '',
                );
              }).toList();

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return CustomCard(user: users[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
