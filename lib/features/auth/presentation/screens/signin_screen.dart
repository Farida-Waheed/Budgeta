// lib/features/auth/presentation/screens/signin_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';
import '../../../../app/router.dart';
import '../../data/phone_auth_service.dart';
import '../../../../core/constants/country_codes.dart';

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
    final sanitized = rawInput.startsWith('0')
        ? rawInput.substring(1)
        : rawInput;
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
            final UserCredential userCredential = await FirebaseAuth.instance
                .signInWithCredential(credential);
            if (userCredential.user != null && mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
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
      hintStyle: const TextStyle(color: BudgetaColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.pink.shade100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.pink.shade100),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: BudgetaColors.primary, width: 1.6),
      ),
    );
  }

  InputDecoration _nameDecoration() {
    return InputDecoration(
      labelText: 'Full name',
      prefixIcon: const Icon(Icons.person),
      labelStyle: const TextStyle(fontSize: 13, color: BudgetaColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.pink.shade100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.pink.shade100),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: BudgetaColors.primary, width: 1.6),
      ),
    );
  }

  // ------- perks row like login/forgot -------

  Widget _perksRow() {
    const labelStyle = TextStyle(
      fontSize: 11,
      color: BudgetaColors.textMuted,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _perk(
            icon: Icons.phone_iphone_rounded,
            label: 'One-tap login',
            style: labelStyle,
          ),
          _perk(
            icon: Icons.password_rounded,
            label: 'No password needed',
            style: labelStyle,
          ),
          _perk(
            icon: Icons.timer_rounded,
            label: 'Code in seconds',
            style: labelStyle,
          ),
        ],
      ),
    );
  }

  Widget _perk({
    required IconData icon,
    required String label,
    required TextStyle style,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: BudgetaColors.primary),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: style,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: Column(
        children: [
          // 🌈 Gradient header, same style as login/forgot
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 44, // cover status bar
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [BudgetaColors.primary, BudgetaColors.deep],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Log in or sign up',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Step into a world of better money choices ✨',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 16),

                // mini glass info card (like login/coach)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.20),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.sms_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Use your phone number for a quick, password-free glow-up login ✨',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 💳 Body card centered vertically (same pattern as login/forgot)
          Expanded(
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 18),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  22,
                                  20,
                                  20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.pink.shade50,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.10,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Enter your details',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: BudgetaColors.deep,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'We’ll send a code to verify your number.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: BudgetaColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 18),

                                    TextField(
                                      controller: _nameController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: _nameDecoration(),
                                    ),
                                    const SizedBox(height: 16),

                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.pink.shade100,
                                            ),
                                          ),
                                          child: DropdownButton<String>(
                                            value: countryCode,
                                            underline: const SizedBox(),
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                            ),
                                            items: CountryCodes.codes.map((c) {
                                              final flag = getFlagEmoji(
                                                c['iso'] ?? '',
                                              );
                                              return DropdownMenuItem<String>(
                                                value: c['code'],
                                                child: Text(
                                                  '$flag ${c['code']}',
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(
                                                  () => countryCode = value,
                                                );
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
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                            decoration: _phoneDecoration(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    const Text.rich(
                                      TextSpan(
                                        text:
                                            'By proceeding, you agree to our ',
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
                                        onPressed: _isLoading
                                            ? null
                                            : _startPhoneVerification,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              BudgetaColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
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
                          const SizedBox(height: 22),
                          _perksRow(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
