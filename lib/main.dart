import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mswhd/firebase_options.dart';
import 'package:mswhd/screens/chat_screen.dart';
import 'package:mswhd/screens/onboarding_screen.dart';
import 'package:mswhd/screens/test_uploading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/main_screen.dart';
import 'screens/registration_page.dart';
import 'screens/notifications_page.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    _loadThemeMode();
    _checkFirstLaunch();
    _updateSystemUIOverlay();
  }

  void _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
    if (isFirstLaunch) {
      await prefs.setBool('first_launch', false);
    } else {
      setState(() {
        _showSplash = false;
      });
    }
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    String? themeMode = prefs.getString('theme_mode');
    setState(() {
      if (themeMode != null) {
        _themeMode = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
      } else {
        var brightness = SchedulerBinding.instance.window.platformBrightness;
        _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }
      _updateSystemUIOverlay();
    });
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
        prefs.setString('theme_mode', 'light');
      } else {
        _themeMode = ThemeMode.dark;
        prefs.setString('theme_mode', 'dark');
      }
      _updateSystemUIOverlay();
    });
  }

  void _updateSystemUIOverlay() {
    final isDarkMode = _themeMode == ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode ? Colors.black : Colors.white,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDarkMode ? ThemeData.dark().primaryColor : ThemeData.light().scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSW HD',
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: _showSplash ? '/splash' : '/main',
      routes: {
        '/splash': (context) => SplashScreen(toggleTheme: _toggleTheme),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/main': (context) => MainScreen(toggleTheme: _toggleTheme),
        '/notifications': (context) => const NotificationsPage(),
        '/chats': (context) => const ChatScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/test_upload': (context) => const TestUploading()
      },
    );
  }
}
