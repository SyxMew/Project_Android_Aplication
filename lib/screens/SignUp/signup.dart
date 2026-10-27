import 'package:flutter/material.dart';
import 'package:food_app/screens/Login/login.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/logo grey.png'),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        localizations?.create_account ?? 'Create Account',
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 80),
                      TextField(
                        controller: authProvider.emailController,
                        decoration: InputDecoration(
                          labelText: localizations?.email ?? 'Email',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      TextField(
                        controller: authProvider.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: localizations?.password ?? 'Password',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      TextField(
                        controller: authProvider.confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: localizations?.confirm_password ??
                              'Confirm Password',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                      ElevatedButton(
                        onPressed: (() {
                          final email =
                              authProvider.emailController.text.trim();
                          final password =
                              authProvider.passwordController.text.trim();
                          final confirmPassword = authProvider
                              .confirmPasswordController.text
                              .trim();

                          if (email.isEmpty ||
                              password.isEmpty ||
                              confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations?.fill_all_fields ??
                                    'Please fill all fields!'),
                              ),
                            );
                          } else if (password != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    localizations?.password_mismatch ??
                                        'Passwords do not match!'),
                              ),
                            );
                          } else {
                            authProvider.isLogin = false;
                            authProvider.submit(context);
                          }
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(localizations?.sign_up ?? 'Sign Up'),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          authProvider.toggleMode();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: localizations?.already_have_account ??
                                    'Already have an account? ',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Itim',
                                ),
                              ),
                              TextSpan(
                                text: localizations?.sign_in ?? 'Sign In',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Itim',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
