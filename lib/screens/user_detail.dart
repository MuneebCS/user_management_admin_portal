// }
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/admin_authprovider.dart';
import '../widgets/custm_button.dart';
import '../widgets/custom_textfield.dart';
import 'homepage.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({required this.user});

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
    print('User UID in initState: ${widget.user.uid}');
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

    try {
      await authProvider.editUser(
        widget.user.uid,
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim(),
        profileImageBytes: _profileImageBytes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User details updated successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);

      try {
        await authProvider.deleteUser(widget.user.uid);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Edit User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _deleteUser,
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
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                backgroundImage: _profileImageBytes != null
                    ? MemoryImage(_profileImageBytes!)
                    : (widget.user.profileImageUrl.isNotEmpty
                        ? NetworkImage(widget.user.profileImageUrl)
                        : const AssetImage('assets/default_profile_image.png')
                            as ImageProvider),
                child: const Align(
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
            )
          ],
        ),
      ),
    );
  }
}
