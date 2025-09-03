import 'package:flutter/material.dart';
import 'package:roomie/theme/app_theme.dart';
import 'auth_services.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthServices _authService = AuthServices();
  bool _isLoading = false;
  String _message = "";
  bool _isSuccess = false;

  void _resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      setState(() {
        _message = "Please enter your email address";
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = "";
    });

    try {
      await _authService.resetpassword(emailController.text.trim());
      setState(() {
        _message = "Password reset email sent! Please check your inbox.";
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _message = "Error: $e";
        _isSuccess = false;
      });
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

                // Header Section with glassmorphic effect
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
                          Icons.lock_reset,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Forgot Password?",
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "No worries! Enter your email and we'll send you reset instructions.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Reset Form with glassmorphic effect
                Container(
                  decoration: AppTheme.glassmorphicCardDecoration,
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Reset Password",
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
                          labelText: "Email Address",
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          hintText: "Enter your email address",
                        ),
                      ),
                      SizedBox(height: 24),

                      // Reset Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
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
                                "Send Reset Link",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),

                      // Message Display
                      if (_message.isNotEmpty) ...[
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isSuccess
                                ? AppTheme.successGreen.withOpacity(0.1)
                                : AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.glassBorderRadius,
                            ),
                            border: Border.all(
                              color: _isSuccess
                                  ? AppTheme.successGreen.withOpacity(0.3)
                                  : AppTheme.errorRed.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isSuccess ? Icons.check_circle : Icons.error,
                                color: _isSuccess
                                    ? AppTheme.successGreen
                                    : AppTheme.errorRed,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _message,
                                  style: TextStyle(
                                    color: _isSuccess
                                        ? AppTheme.successGreen
                                        : AppTheme.errorRed,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Back to Login Button
                Container(
                  decoration: AppTheme.glassmorphicDecoration,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Back to Login"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: AppTheme.lightGrey.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.glassBorderRadius,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Help Section with glassmorphic effect
                Container(
                  decoration: AppTheme.glassmorphicCardDecoration,
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: AppTheme.textSecondary,
                        size: 32,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Need Help?",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "If you're still having trouble, contact our support team.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Contact support functionality
                        },
                        child: Text("Contact Support"),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.lightGrey.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
