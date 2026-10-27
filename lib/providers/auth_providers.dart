// auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app/models/auth.dart';
import 'package:food_app/screens/admin/chat%20admin/chat_admin.dart';
import 'package:food_app/screens/home/home.dart';
import 'package:food_app/screens/Login/login.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLogin = true;
  User? currentUser;

  AuthProvider() {
    _checkUserLoginStatus();
  }

  void toggleMode() {
    isLogin = !isLogin;
    notifyListeners();
  }

  Future<void> _checkUserLoginStatus() async {
    String? savedEmail = await _authService.getUserFromPrefs();
    if (savedEmail != null) {
      currentUser = await _authService.login(savedEmail, '');  
      notifyListeners();
    }
  }

  Future<void> submit(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Check email format
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    // Check password
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    if (isLogin) {
      // Login logic
      try {
        final user = await _authService.login(email, password);
        if (user != null) {
          currentUser = user;
          notifyListeners();
          if (email == 'admin@gmail.com' && password == 'admin123') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminChatScreen(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        } else {
          // Login failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      } catch (e) {
        // Handle error (e.g., network issue)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } else {
      // Sign up logic
      try {
        final user = await _authService.signUp(email, password);
        if (user != null) {
          currentUser = user;
          notifyListeners();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration failed!")),
          );
        }
        toggleMode();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logout();
    currentUser = null;
    notifyListeners();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  String? get currentEmail {
    return currentUser?.email;
  }

  String? get currentUserName {
    if (currentEmail != null) {
      return currentEmail!.split('@')[0];
    }
    return null;
  }
}
