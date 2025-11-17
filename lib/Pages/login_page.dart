import 'package:flutter/material.dart';
import '../widget/custom_text_field.dart';
import '../widget/gradient_button.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  void _login() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Attempt login using AuthService with remember me option
    final result = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
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

      // Navigate to home page if login successful
      if (result['success']) {
        final user = result['user'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userName: user.fullName,
              userEmail: user.email,
            ),
          ),
        );
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
                const SizedBox(height: 40),

                // Eco Logo
                _buildEcoLogo(),
                const SizedBox(height: 40),

                // Welcome Text
                _buildEcoWelcomeText(),
                const SizedBox(height: 40),

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
                  hintText: 'Enter your password',
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
                const SizedBox(height: 16),

                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(
                      'Remember me',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Forgot password feature coming soon!'),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Login Button
                GradientButton(
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                  text: 'Sign In to Eco Guardians',
                ),
                const SizedBox(height: 30),

                // Divider
                _buildEcoDivider(),
                const SizedBox(height: 30),

                // Social Login Buttons
                _buildEcoSocialLogin(),
                const SizedBox(height: 30),

                // Sign Up Link
                _buildEcoSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEcoLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade400,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.eco,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Eco Guardians',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEcoWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back, Eco Warrior!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sign in to continue your environmental journey and track your impact',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
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

  Widget _buildEcoSocialLogin() {
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

  Widget _buildEcoSignUpLink() {
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
            "New to Eco Guardians? ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            child: Text(
              'Join Now',
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}