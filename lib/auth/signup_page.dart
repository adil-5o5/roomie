import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomie/home/home_page.dart';
import 'package:roomie/widgets/customappbar.dart';
import 'package:roomie/theme/app_theme.dart';
import 'auth_services.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  //emailcontrollers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthServices _authService = AuthServices();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  //sign up
  void _signup() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    //password not match
    if (passwordController.text == confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    //pasword length
    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password must be at least 6 characters"),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await _authService.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup Error: $e"),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),

                // Logo/Brand Section with glassmorphic effect
                Container(
                  decoration: AppTheme.glassmorphicDecoration,
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Join Roomie",
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Create your account to start finding rooms",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 60),

                // Sign Up Form with glassmorphic effect
                Container(
                  decoration: AppTheme.glassmorphicCardDecoration,
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Sign Up",
                        style: Theme.of(context).textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),

                      // Email Field
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Confirm Password Field
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 32),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
