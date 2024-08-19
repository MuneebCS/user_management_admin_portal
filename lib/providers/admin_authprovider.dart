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
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch users. Please try again.';
      notifyListeners();
      return [];
    }
  }

  Future<void> editUser(
    String uid, {
    required String email,
    required String fullName,
    Uint8List? profileImageBytes,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);

      // If a new profile image is provided, upload it and get the URL
      String? imageUrl;
      if (profileImageBytes != null) {
        String filePath = 'profile_images/$uid.jpg';
        final uploadTask = _storage.ref(filePath).putData(profileImageBytes);
        imageUrl = await (await uploadTask).ref.getDownloadURL();
      }

      final userData = {
        'email': email,
        'fullName': fullName,
        'profileImageUrl':
            imageUrl, // This will be null if no new image was uploaded
      };

      await userRef.update(userData);
    } catch (e) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      await userRef.delete();
    } catch (e) {
      throw Exception('Failed to delete user');
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    super.dispose();
  }
}
