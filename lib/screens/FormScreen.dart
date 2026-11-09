import 'package:flutter/material.dart';

import 'loginScreen.dart';

class MyForm extends StatefulWidget {
  final Future<void> Function() onLogin;

  const MyForm({
    super.key,
    required this.onLogin,
  });

  @override
  State<MyForm> createState() => _MyFormState();
}
class _MyFormState extends State<MyForm> {

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (value) => (value == null || value.isEmpty)
                  ? "Le champ ne peut pas etre vide"
                  : null,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              validator: (value) => (value == null || value.isEmpty)
                  ? "Le champ ne peut pas etre vide"
                  : null,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await widget.onLogin();
              }
            },
            child: const Text("Se connecter"),
          ),

        ],
      ),
    );
  }
}