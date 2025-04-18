import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _fetchUserData(user.uid);
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _fetchUserData(userCredential.user!.uid);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  // Register new user
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String userType,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Create user profile in Firestore
        final UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          userType: userType,
        );
        
        await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
        
        _currentUser = newUser;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        _currentUser = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      await _firestore.collection('users').doc(updatedUser.id).update(updatedUser.toJson());
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }
}