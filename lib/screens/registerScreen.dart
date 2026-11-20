
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/services/authState.dart';

import '../services/authService.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();

  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool acceptTerms = false;
  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleRegister() async {
    if (!formKey.currentState!.validate()) return;

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tu dois accepter les conditions d’utilisation.',
          ),
        ),
      );
      return;
    }

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() => isLoading = true);

    try {
      await authService.register(
        username: username,
        email: email,
        password: password,
        acceptTerms: acceptTerms,
      );

      // Récupération du profil et du statut des favoris
      await authState.refresh();

      if (!mounted) return;

      if (!authState.isAuthenticated) {
        throw Exception(
          'Compte créé, mais impossible de récupérer la session.',
        );
      }

      // GoRouter décidera de la destination.
      context.go('/');

    } catch (error, stackTrace) {
      debugPrint('REGISTER ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() => isLoading = false);

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
        title: const Text('Créer un compte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d’utilisateur',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Entre un nom d’utilisateur.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Adresse e-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Adresse e-mail invalide.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Minimum 8 caractères.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Les mots de passe ne correspondent pas.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CheckboxListTile(
                value: acceptTerms,
                onChanged: (value) {
                  setState(() {
                    acceptTerms = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'J’accepte les conditions d’utilisation et la politique de confidentialité.',
                ),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : handleRegister,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Créer mon compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

