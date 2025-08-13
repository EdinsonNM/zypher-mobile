// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'core/providers/student_provider.dart';
import 'core/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xirezgaautlmbfucrjpj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhpcmV6Z2FhdXRsbWJmdWNyanBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUzMzI3MDIsImV4cCI6MjA1MDkwODcwMn0.QqGT2GfKrDkgqEoYtieOnLqsiQ-QHUKefPAj88b1tOg',
  );

  await initializeDateFormatting('es');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Enrollment App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
        ),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF60A5FA),
          secondary: const Color(0xFF60A5FA),
          surface: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF60A5FA),
          unselectedItemColor: const Color(0xFF6B7280),
          type: BottomNavigationBarType.fixed,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF111827),
        cardColor: const Color(0xFF1F2937),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF111827),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF60A5FA),
          secondary: const Color(0xFF60A5FA),
          surface: const Color(0xFF1F2937),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF111827),
          selectedItemColor: const Color(0xFF60A5FA),
          unselectedItemColor: const Color(0xFF6B7280),
          type: BottomNavigationBarType.fixed,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF111827),
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
