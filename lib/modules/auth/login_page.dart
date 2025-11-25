import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../state/auth_provider.dart';
import '../home/home_nav.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              AppTextField(
                label: "Email",
                controller: email,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Email required";
                  if (!v.contains("@")) return "Invalid email";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: "Password",
                controller: password,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Password required";
                  if (v.length < 6) return "Min 6 characters";
                  return null;
                },
              ),

              const SizedBox(height: 24),

              AppButton(
                text: loading ? "Loading..." : "Login",
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  setState(() => loading = true);

                  final error = await auth.login(
                    email.text.trim(),
                    password.text.trim(),
                  );

                  setState(() => loading = false);

                  if (!mounted) return;

                  if (error != null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error)));
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeNav()),
                  );
                },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      );
                    },
                    child: const Text("Sign up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
