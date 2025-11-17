import 'package:flutter/material.dart';
import 'package:projectwithlouled/Widget/custom_text_field.dart';
import 'package:projectwithlouled/widget/gradient_button.dart';
import '../services/auth_service.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  void _signup() async {
    // Basic validation
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Attempt signup using AuthService
    final result = await _authService.signUp(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    // Show result message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green.shade600 : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to login after successful signup
      if (result['success']) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF1F8E9),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Back button and Logo
                _buildEcoHeader(context),
                const SizedBox(height: 40),

                // Welcome Text
                _buildEcoWelcomeText(),
                const SizedBox(height: 40),

                // Full Name Field
                CustomTextField(
                  controller: _fullNameController,
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 20),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.green.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.green.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 25),

                // Terms and Conditions
                _buildEcoTermsCheckbox(),
                const SizedBox(height: 30),

                // Sign Up Button
                GradientButton(
                  onPressed: _isLoading ? null : _signup,
                  isLoading: _isLoading,
                  text: 'Join Eco Community',
                ),
                const SizedBox(height: 30),

                // Divider
                _buildEcoDivider(),
                const SizedBox(height: 30),

                // Social Sign Up Buttons
                _buildEcoSocialSignup(),
                const SizedBox(height: 30),

                // Login Link
                _buildEcoLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEcoHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.green.shade700,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Spacer(),
        // Eco Logo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade400,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.eco,
            color: Colors.white,
            size: 32,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48), // For balance
      ],
    );
  }

  Widget _buildEcoWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.eco,
              color: Colors.green.shade600,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              'Join Eco Guardians',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Create your account and start making a positive environmental impact',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildEcoTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _agreeToTerms ? Colors.green.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreeToTerms ? Colors.green.shade600 : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Theme(
              data: ThemeData(
                unselectedWidgetColor: Colors.transparent,
              ),
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                activeColor: Colors.transparent,
                checkColor: Colors.green.shade600,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.green.shade200,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.green.shade200,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEcoSocialSignup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildEcoSocialButton(
          icon: Icons.g_mobiledata,
          label: 'Google',
          onPressed: () {},
          color: Colors.red.shade500,
        ),
        const SizedBox(width: 16),
        _buildEcoSocialButton(
          icon: Icons.facebook,
          label: 'Facebook',
          onPressed: () {},
          color: Colors.blue.shade600,
        ),
        const SizedBox(width: 16),
        _buildEcoSocialButton(
          icon: Icons.apple,
          label: 'Apple',
          onPressed: () {},
          color: Colors.black,
        ),
      ],
    );
  }

  Widget _buildEcoSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade100,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEcoLoginLink() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already part of our community? ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}