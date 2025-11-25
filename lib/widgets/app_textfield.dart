import 'package:flutter/material.dart';
import '../config/theme/colors.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;   // <-- ADDED
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,              // <-- ADDED
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),

        // 🔥 TextFormField (supports validator)
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          validator: validator,     // <-- ADDED
          enabled: enabled,

          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightGrey,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 12),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),

            // 🔥 Error styling
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
