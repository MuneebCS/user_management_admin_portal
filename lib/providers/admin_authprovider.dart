import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  Uint8List? _profileImageBytes; // For web

  String _errorMessage = '';
  bool _isLoading = false;

  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void setProfileImageBytes(Uint8List imageBytes) {
    _profileImageBytes = imageBytes;
    notifyListeners();
  }

  Future<bool> loginAdmin() async {
    String password = passwordController.text;
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot adminSnapshot = await _firestore
          .collection('admins')
          .where('password', isEqualTo: password)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Incorrect password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } finally {
      passwordController.clear();
    }
  }

  Future<void> addUser() async {
    _errorMessage = '';
    notifyListeners();

    String email = emailController.text.trim();
    String password = passwordController.text;
    String fullName = fullNameController.text.trim();

    if (_profileImageBytes == null) {
      _errorMessage = 'Please upload a profile image to continue.';
      notifyListeners();
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String filePath = 'profile_images/${userCredential.user!.uid}.jpg';

      // Convert bytes to a file for upload
      final uploadTask = _storage.ref(filePath).putData(_profileImageBytes!);
      String imageUrl = await (await uploadTask).ref.getDownloadURL();

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'fullName': fullName,
        'profileImageUrl': imageUrl,
      });
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      emailController.clear();
      passwordController.clear();
      fullNameController.clear();

      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> viewAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch users. Please try again.';
      notifyListeners();
      return [];
    }
  }

  Future<void> editUser(
    String uid, {
    String? email,
    String? fullName,
    Uint8List? profileImageBytes,
    required String userId,
  }) async {
    _errorMessage = '';
    notifyListeners();

    try {
      Map<String, dynamic> updateData = {};

      if (email != null) {
        updateData['email'] = email;
        // Update the email in FirebaseAuth as well
        User? currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid == uid) {
          await currentUser.updateEmail(email);
        }
      }
      if (fullName != null) {
        updateData['fullName'] = fullName;
      }
      if (profileImageBytes != null) {
        String filePath = 'profile_images/$uid.jpg';
        final uploadTask = _storage.ref(filePath).putData(profileImageBytes);
        String imageUrl = await (await uploadTask).ref.getDownloadURL();
        updateData['profileImageUrl'] = imageUrl;
      }

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updateData);
      }
    } catch (e) {
      _errorMessage = 'Failed to update user. Please try again.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteUser(String uid) async {
    _errorMessage = '';
    notifyListeners();

    try {
      // Delete user from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Delete user from FirebaseAuth
      User? user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        await user.delete();
      } else {
        await _auth.currentUser!.delete();
      }
    } catch (e) {
      _errorMessage = 'Failed to delete user. Please try again.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _errorMessage = 'Failed to logout. Please try again.';
      notifyListeners();
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'The user corresponding to the given email has been disabled.';
      case 'user-not-found':
        return 'No user corresponding to the given email.';
      case 'wrong-password':
        return 'The password is invalid for the given email.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password must be 6 characters long or more.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    super.dispose();
  }
}
