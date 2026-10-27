import 'package:flutter/material.dart';
import 'package:food_app/providers/auth_providers.dart';
import 'package:food_app/screens/SignUp/signup.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key to handle validation

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context); // Get localized strings

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        localizations?.login ?? 'Login', // Use localized string
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 140),
                      Form(
                        key: _formKey, // Assign the form key
                        child: Column(
                          children: [
                            TextFormField(
                              controller: authProvider.emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: localizations?.email ??
                                    'Email', // Use localized string
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return localizations?.fill_email ??
                                      'Please enter your email'; // Localized error message
                                } else if (!value.contains('@')) {
                                  return localizations?.invalid_email ??
                                      'Please enter a valid email address'; // Localized error message
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 35),
                            TextFormField(
                              controller: authProvider.passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: localizations?.password ??
                                    'Password', // Use localized string
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return localizations?.fill_password ??
                                      'Please enter your password'; // Localized error message
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            authProvider.submit(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(localizations?.sign_in ??
                            'Sign in'), // Use localized string
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          authProvider.toggleMode();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: localizations?.no_account ??
                                    "Don't have an account? ", // Localized string
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Itim',
                                ),
                              ),
                              TextSpan(
                                text: localizations?.sign_up ??
                                    'Sign Up', // Localized string
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
