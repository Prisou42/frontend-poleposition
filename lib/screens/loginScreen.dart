import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/authService.dart';
import 'FormScreen.dart';

final authService = AuthService();
final emailController = TextEditingController();
final passwordController = TextEditingController();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<void> handleLogin() async {
    try {
      final user = await AuthService().login(
        emailController.text,
        passwordController.text,
      );

      if (!mounted) return;

      context.go('/login', extra: user);;

    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PolePosition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MyForm(
          onLogin: handleLogin,
        ),
      ),
    );
  }
}





