import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/admin_authprovider.dart';
import '../widgets/custom_textfield.dart';

class NewUser extends StatefulWidget {
  @override
  State<NewUser> createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  bool _obscurePassword = true;
  Uint8List? _profileImageBytes;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
      Provider.of<AuthenticationProvider>(context, listen: false)
          .setProfileImageBytes(_profileImageBytes!);
    }
  }

  Future<void> _createNewUser() async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    if (_profileImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please upload a profile image to continue.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await authProvider.addUser();

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authProvider.errorMessage.isEmpty
            ? "Account created successfully!"
            : authProvider.errorMessage),
      ),
    );

    // Reset the form and profile image if creation is successful
    if (authProvider.errorMessage.isEmpty) {
      setState(() {
        _profileImageBytes = null;
      });
      authProvider.fullNameController.clear();
      authProvider.emailController.clear();
      authProvider.passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  "New User",
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileImage(),
                const SizedBox(height: 24),
                _buildForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 3,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            radius: 100,
            backgroundImage: _profileImageBytes != null
                ? MemoryImage(_profileImageBytes!)
                : null,
            child: _profileImageBytes == null
                ? Icon(Icons.person,
                    size: 100, color: Theme.of(context).primaryColor)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).secondaryHeaderColor,
              backgroundColor: Theme.of(context).primaryColor,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8.0),
            ),
            child: Icon(Icons.upload,
                color: Theme.of(context).secondaryHeaderColor),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Form(
      child: Column(
        children: [
          CustomTextField(
            controller: authProvider.fullNameController,
            hintText: 'Full Name',
            obscureText: false,
            keyboardType: TextInputType.text,
            prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: authProvider.emailController,
            hintText: 'Email',
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: authProvider.passwordController,
            hintText: 'Password',
            obscureText: _obscurePassword,
            keyboardType: TextInputType.text,
            prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600]),
              onPressed: _togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _createNewUser,
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            child: _isLoading
                ? _buildCircularProgressIndicator()
                : const Text(
                    "Create Account",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto'),
                  ),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildCircularProgressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    );
  }
}
