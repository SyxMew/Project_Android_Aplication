import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserToPrefs(userCredential.user);  
      return userCredential.user;
    } catch (e) {
      print("Registration error: $e");
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserToPrefs(userCredential.user);  
      return userCredential.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _clearUserFromPrefs(); 
    } catch (e) {
      print("Logout error: $e");
    }
  }

  Future<void> _saveUserToPrefs(User? user) async {
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userEmail', user.email!);
    }
  }

  Future<void> _clearUserFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userEmail');
  }

  Future<String?> getUserFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
}
