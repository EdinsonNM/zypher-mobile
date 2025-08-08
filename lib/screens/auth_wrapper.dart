import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  late Stream<AuthState> _authStateStream;

  @override
  void initState() {
    super.initState();
    _authStateStream = Supabase.instance.client.auth.onAuthStateChange;
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Verificar si hay una sesión activa
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        // Verificar si el token no ha expirado
        final expiresAt = session.expiresAt;
        final now = DateTime.now();
        
        if (expiresAt != null) {
          // Convertir el timestamp a DateTime
          final expirationDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
          
          if (now.isBefore(expirationDate)) {
            setState(() {
              _isAuthenticated = true;
              _isLoading = false;
            });
          } else {
            // Token expirado, hacer logout
            await Supabase.instance.client.auth.signOut();
            setState(() {
              _isAuthenticated = false;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking auth state: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        if (_isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si hay un cambio en el estado de autenticación, actualizar
        if (snapshot.hasData) {
          final authState = snapshot.data!;
          _isAuthenticated = authState.session != null;
        }

        if (_isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
