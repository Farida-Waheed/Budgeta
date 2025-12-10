import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';
import '../../../../app/router.dart';
import '../../data/phone_auth_service.dart';
import '../../../../core/constants/country_codes.dart'; // adapt path to where you keep CountryCodes

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final PhoneAuthService _authService = PhoneAuthService();

  String countryCode = '+20';
  bool _isLoading = false;

  String getFlagEmoji(String isoCountryCode) {
    if (isoCountryCode.length != 2) return '';
    return isoCountryCode
        .toUpperCase()
        .codeUnits
        .map((c) => String.fromCharCode(c + 127397))
        .join();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: BudgetaColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _startPhoneVerification() async {
    final rawInput = _phoneController.text.trim();
    final sanitized =
        rawInput.startsWith('0') ? rawInput.substring(1) : rawInput;
    final fullPhone = '$countryCode$sanitized';
    final name = _nameController.text.trim();

    if (sanitized.isEmpty || sanitized.length < 8) {
      _showSnackBar("Enter a valid phone number");
      return;
    }

    if (name.isEmpty) {
      _showSnackBar("Enter your name");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: fullPhone,
        userName: name,
        codeSent: (verificationId) {
          setState(() => _isLoading = false);
          Navigator.pushNamed(
            context,
            AppRoutes.login,
            arguments: {
              'verificationId': verificationId,
              'phone': fullPhone,
              'name': name,
            },
          );
        },
        verificationCompleted: (AuthCredential credential) async {
          try {
            final UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            if (userCredential.user != null) {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          } catch (e) {
            _showSnackBar("Verification failed: $e");
          }
        },
        onError: (error) {
          setState(() => _isLoading = false);
          _showSnackBar("Verification failed: $error");
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Error: $e");
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  InputDecoration _phoneDecoration() {
    return InputDecoration(
      hintText: 'Mobile number',
      hintStyle: const TextStyle(
        color: BudgetaColors.textMuted,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: BudgetaColors.cardBorder.withValues(alpha: 0.9),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(
          color: BudgetaColors.primary,
          width: 1.6,
        ),
      ),
    );
  }

  InputDecoration _nameDecoration() {
    return InputDecoration(
      labelText: 'Full name',
      prefixIcon: const Icon(Icons.person),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: BudgetaColors.textMuted,
      ),
      filled: true,
      fillColor: BudgetaColors.accentLight.withValues(alpha: 0.06),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: BudgetaColors.cardBorder.withValues(alpha: 0.9),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: BudgetaColors.cardBorder.withValues(alpha: 0.7),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(
          color: BudgetaColors.primary,
          width: 1.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Gradient header instead of photo
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [BudgetaColors.primary, BudgetaColors.deep],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log in or sign up',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Step into a world of better money choices ✨',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: BudgetaColors.accentLight
                              .withValues(alpha: 0.9),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _nameDecoration(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: BudgetaColors.cardBorder
                                        .withValues(alpha: 0.9),
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  value: countryCode,
                                  underline: const SizedBox(),
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                  items: CountryCodes.codes.map((c) {
                                    final flag =
                                        getFlagEmoji(c['iso'] ?? '');
                                    return DropdownMenuItem<String>(
                                      value: c['code'],
                                      child: Text('$flag ${c['code']}'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => countryCode = value);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: const TextStyle(fontSize: 15),
                                  decoration: _phoneDecoration(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text.rich(
                            TextSpan(
                              text: 'By proceeding, you agree to our ',
                              children: [
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: TextStyle(
                                    color: BudgetaColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(
                                    color: BudgetaColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: BudgetaColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _startPhoneVerification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BudgetaColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Login or Signup',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
