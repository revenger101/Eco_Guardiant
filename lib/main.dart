import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/signup_page.dart';
import 'services/auth_service.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization service
  await LocalizationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService();

    return ValueListenableBuilder<Locale>(
      valueListenable: localizationService.localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Eco Guardians',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
            useMaterial3: true,
          ),
          // Localization configuration
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocalizationService.supportedLocales,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignupPage(),
            '/home': (context) => HomePage(
              userName: 'User Name',
              userEmail: 'user@example.com',
            ),
          },
        );
      },
    );
  }
}

/// Splash screen that checks for stored credentials and auto-logs in
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    // Show splash screen for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Try auto-login
    final result = await _authService.autoLogin();

    if (!mounted) return;

    if (result['success']) {
      // Auto-login successful, navigate to home
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
    } else {
      // No stored credentials or auto-login failed, go to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Eco Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Eco Guardians',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Protecting Our Planet Together',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}