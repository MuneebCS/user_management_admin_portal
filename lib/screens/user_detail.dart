import 'dart:typed_data'; // Ensure this import is present
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/admin_authprovider.dart';
import '../widgets/custm_button.dart';
import '../widgets/custom_textfield.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  UserDetailScreen({required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  Uint8List? _profileImageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email);
    _fullNameController = TextEditingController(text: widget.user.fullName);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = Uint8List.fromList(imageBytes);
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    await authProvider.editUser(
      widget.user.uid,
      userId: widget.user.uid,
      email: _emailController.text.trim(),
      fullName: _fullNameController.text.trim(),
      profileImageBytes: _profileImageBytes,
    );

    setState(() {
      _isLoading = false;
    });

    if (authProvider.errorMessage.isEmpty) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage)),
      );
    }
  }

  Future<void> _deleteUser() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    await authProvider.deleteUser(widget.user.uid);

    setState(() {
      _isLoading = false;
    });

    if (authProvider.errorMessage.isEmpty) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _isLoading
                ? null
                : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirm'),
                        content:
                            Text('Are you sure you want to delete this user?'),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: Text('Delete'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _deleteUser();
                    }
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageBytes != null
                    ? MemoryImage(_profileImageBytes!)
                    : NetworkImage(widget.user.profileImageUrl)
                        as ImageProvider,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _fullNameController,
              hintText: 'Full Name',
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16.0),
            CustomButton(
              text: _isLoading ? 'Saving...' : 'Save Changes',
              onPressed: _isLoading
                  ? () {}
                  : () async {
                      await _saveChanges();
                    },
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
