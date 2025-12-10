import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required String userName,
    required Function(String verificationId) codeSent,
    required Function(AuthCredential credential) verificationCompleted,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final UserCredential userCredential = await _auth
                .signInWithCredential(credential);

            if (userCredential.user != null) {
              await _saveUserToFirestore(
                userCredential.user!,
                phoneNumber,
                userName,
              );
            }

            verificationCompleted(credential);
          } catch (e) {
            onError('Auto verification failed: $e');
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },

        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError('Phone verification error: $e');
    }
  }

  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String userName,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!, phoneNumber, userName);
      }

      return userCredential;
    } catch (e) {
      throw Exception('OTP sign-in failed: $e');
    }
  }

  Future<void> _saveUserToFirestore(
    User user,
    String phone,
    String name,
  ) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'phone': phone,
          'email': user.email ?? '',
          'name': name,
          'address': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('users').doc(user.uid).update({
          'phone': phone,
          'name': name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      throw Exception('Failed to save user data: $e');
    }
  }
}
