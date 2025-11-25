import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../state/auth_provider.dart';
import '../home/home_nav.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final income = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                AppTextField(
                  label: "Full name",
                  controller: name,
                  validator: (v) =>
                      v!.isEmpty ? "Name cannot be empty" : null,
                ),

                const SizedBox(height: 16),

                AppTextField(
                  label: "Email",
                  controller: email,
                  validator: (v) {
                    if (v!.isEmpty) return "Email required";
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
                    if (v!.isEmpty) return "Password required";
                    if (v.length < 6) return "Min 6 characters";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  label: "Confirm password",
                  controller: confirmPassword,
                  isPassword: true,
                  validator: (v) {
                    if (v!.isEmpty) return "Confirm your password";
                    if (v != password.text) return "Passwords do not match";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  label: "Monthly income (optional)",
                  controller: income,
                  validator: (v) {
                    if (v!.isEmpty) return null;
                    final num? parsed = num.tryParse(v);
                    if (parsed == null || parsed < 0) {
                      return "Invalid income";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                AppButton(
                  text: loading ? "Creating..." : "Sign Up",
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    setState(() => loading = true);

                    final error = await auth.signup(
                      name.text.trim(),
                      email.text.trim(),
                      password.text.trim(),
                    );

                    setState(() => loading = false);

                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                      return;
                    }

                    // Add optional income
                    if (income.text.trim().isNotEmpty) {
                      final parsed = double.tryParse(income.text.trim());
                      if (parsed != null && parsed >= 0) {
                        auth.updateMonthlyIncome(parsed);
                      }
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeNav()),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text("Log in"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
