
import 'package:flutter/material.dart';

class MyForm extends StatefulWidget {
  final Future<void> Function(String email, String password) onLogin;

  const MyForm({
    super.key,
    required this.onLogin,
  });

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate() || isLoading) return;

    setState(() => isLoading = true);

    try {
      await widget.onLogin(
        emailController.text.trim(),
        passwordController.text,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Adresse e-mail',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Entre ton adresse e-mail.';
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
              if (value == null || value.isEmpty) {
                return 'Entre ton mot de passe.';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: isLoading ? null : handleLogin,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Se connecter'),
          ),
        ],
      ),
    );
  }
}
