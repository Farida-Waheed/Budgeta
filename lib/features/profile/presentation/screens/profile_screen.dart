import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/theme.dart';
import '../../../../shared/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> _fetchUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        debugPrint('No user data found in Firestore for $uid');
        return {};
      }

      final data = doc.data() ?? {};
      debugPrint('Fetched user data: $data');
      return data;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in to view your profile.',
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      bottomNavigationBar: const BudgetaBottomNav(
        currentIndex: 4,
      ), // 👈 change index if needed
      body: SafeArea(
        // 🔹 Let the gradient header paint under the status bar
        top: false,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchUserData(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ProfileErrorState(
                message: 'Error loading profile: ${snapshot.error}',
                onRetry: () {
                  // Force FutureBuilder to rebuild
                  (context as Element).reassemble();
                },
              );
            }

            final data = snapshot.data ?? {};

            final userName =
                data['name'] ??
                user.displayName ??
                (user.email?.split('@').first ?? 'Lovely Human');
            final userEmail = data['email'] ?? user.email ?? 'No email';
            final userAddress = data['address'] ?? 'No address set';
            final userPhotoUrl = (data['photoUrl'] ?? user.photoURL) as String?;

            return Column(
              children: [
                _ProfileHeader(
                  name: userName,
                  email: userEmail,
                  photoUrl: userPhotoUrl,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: [
                      _ProfileCard(
                        name: userName,
                        email: userEmail,
                        address: userAddress,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Account actions',
                        style: TextStyle(
                          color: BudgetaColors.deep,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _LogoutTile(
                        onLogout: () async {
                          await FirebaseAuth.instance.signOut();

                          // TODO: change to your real sign-in route
                          // Example if you have a named route:
                          // Navigator.pushNamedAndRemoveUntil(
                          //   context,
                          //   '/signin',
                          //   (route) => false,
                          // );
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// =================== HEADER (gradient like Dashboard / Challenges) =========
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;

  const _ProfileHeader({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  String _initials(String n) {
    final parts = n.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Include status bar height so header looks tall & rich like other screens
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: topPadding + 16,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [BudgetaColors.primary, BudgetaColors.deep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                ? NetworkImage(photoUrl!)
                : null,
            child: (photoUrl == null || photoUrl!.isEmpty)
                ? Text(
                    _initials(name),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, $name 💖',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                const Text(
                  'This is your Budgeta identity. Shine bright ✨',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =================== PROFILE CARD ==========================================
class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String address;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: BudgetaColors.accentLight.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile details',
            style: TextStyle(
              color: BudgetaColors.deep,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(icon: Icons.person, label: 'Name', value: name),
          const SizedBox(height: 12),
          _DetailRow(icon: Icons.email_rounded, label: 'Email', value: email),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.location_on_rounded,
            label: 'Address',
            value: address,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BudgetaColors.accentLight.withValues(alpha: 0.3),
          ),
          child: Icon(icon, size: 18, color: BudgetaColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: BudgetaColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: BudgetaColors.deep,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// =================== LOGOUT TILE ===========================================
class _LogoutTile extends StatelessWidget {
  final Future<void> Function() onLogout;

  const _LogoutTile({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: BudgetaColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: BudgetaColors.primary),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: BudgetaColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'We’ll be here when you come back 💕',
          style: TextStyle(fontSize: 11, color: BudgetaColors.textMuted),
        ),
        onTap: () async {
          await onLogout();
        },
      ),
    );
  }
}

/// =================== ERROR STATE WIDGET ====================================
class _ProfileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BudgetaColors.deep, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: BudgetaColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
