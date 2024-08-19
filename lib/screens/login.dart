import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_management_admin_portal/screens/homepage.dart';
import '../providers/admin_authprovider.dart';
import '../widgets/custm_button.dart';
import '../widgets/custom_textfield.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true;
  bool success = false;
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 360, // Adjusted width for a better fit
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                  12.0), // Increased border radius for modern look
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
                    "Admin",
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 28, // Slightly smaller for balance
                      fontWeight:
                          FontWeight.w600, // Medium weight for readability
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(
                      height: 24), // Increased spacing for better layout
                  CustomTextField(
                    controller: authProvider.passwordController,
                    hintText: 'Password',
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.text,
                    prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 24),
                  authProvider.isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).secondaryHeaderColor,
                        )
                      : _loginButton(authProvider, context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  CustomButton _loginButton(
      AuthenticationProvider authProvider, BuildContext context) {
    return CustomButton(
        text: "Login",
        onPressed: () async {
          authProvider.isLoading
              ? null
              : success = await authProvider.loginAdmin();

          if (success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }
}
