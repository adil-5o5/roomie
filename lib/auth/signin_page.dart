import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomie/auth/forgotpassword_page.dart';
import 'package:roomie/auth/signup_page.dart';
import 'package:roomie/home/home_page.dart';
import 'package:roomie/widgets/customappbar.dart';
import 'package:roomie/theme/app_theme.dart';
import 'auth_services.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  //text editing controller save text and loading and obscure
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthServices _authServices = AuthServices();
  bool _isLoading = false;
  bool _obscurePassword = true;

  //if text field is empyt?
  void _login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("please fill the fields"),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    //try catch
    try {
      User? user = await _authServices.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      //
      if (user != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //google login
  void _googleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await _authServices.googleSignIn();

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Login Error: $e"),
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
                          Icons.meeting_room,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Welcome Back",
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Sign in to continue roomie",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 60),

                // Login Form with glassmorphic effect
                Container(
                  decoration: AppTheme.glassmorphicCardDecoration,
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Login",
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
                      SizedBox(height: 8),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text("Forgot Password?"),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
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
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      SizedBox(height: 20),

                      // Divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Divider(color: AppTheme.lightGrey)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                          Expanded(child: Divider(color: AppTheme.lightGrey)),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Google Sign In Button
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _googleSignIn,
                        icon: Icon(Icons.g_mobiledata, size: 24),
                        label: Text(
                          "Continue with Google",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppTheme.lightGrey.withOpacity(0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.glassBorderRadius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignupPage()),
                        );
                      },
                      child: Text(
                        "Sign Up",
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
