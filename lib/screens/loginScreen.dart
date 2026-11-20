
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/authService.dart';
import '../services/authState.dart';
import 'FormScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();

  Future<void> handleLogin(String email, String password) async {
    try {
      await authService.login(email, password);

      // Récupération du profil et du statut des favoris
      await authState.refresh();

      if (!mounted) return;

      if (!authState.isAuthenticated) {
        throw Exception('Impossible de récupérer votre session.');
      }

      // GoRouter décidera de la destination :
      // sélection des favoris ou accueil.
      context.go('/');

    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PolePosition'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              const Text(
                'Bienvenue sur PolePosition',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              MyForm(
                onLogin: handleLogin,
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  context.go('/register');
                },
                child: const Text(
                  'Pas encore de compte ? Inscris-toi',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PolePosition'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              const Text(
                'Bienvenue sur PolePosition',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              MyForm(
                onLogin: handleLogin,
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  context.go('/register');
                },
                child: const Text(
                  'Pas encore de compte ? Inscris-toi',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





