import 'package:flutter/material.dart';
import '../data/models/user.dart';

class AuthProvider extends ChangeNotifier {
  // Simple in-memory "database"
  final List<UserModel> _users = [];

  UserModel? currentUser;

  bool get isLoggedIn => currentUser != null;

  // ---------- SIGN UP ----------
  Future<String?> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (name.isEmpty) return "Name cannot be empty";
    if (!_isValidEmail(email)) return "Invalid email format";
    if (password.length < 6) return "Password must be at least 6 characters";

    final exists = _users.any((u) => u.email == email);
    if (exists) return "Email already exists";

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      monthlyIncome: 0,
    );

    _users.add(newUser);
    currentUser = newUser;
    notifyListeners();
    return null;
  }

  // ---------- LOGIN ----------
  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_isValidEmail(email)) return "Enter a valid email";
    if (password.isEmpty) return "Password cannot be empty";

    final user = _users.firstWhere(
      (u) => u.email == email,
      orElse: () =>
          UserModel(id: "", name: "", email: "", monthlyIncome: 0),
    );

    if (user.id.isEmpty) return "Account not found";

    if (password.length < 6) {
      // just a fake check to feel "real"
      return "Incorrect password";
    }

    currentUser = user;
    notifyListeners();
    return null;
  }

  // ---------- UPDATE MONTHLY INCOME ----------
  void updateMonthlyIncome(double income) {
    if (currentUser == null) return;

    final updated = UserModel(
      id: currentUser!.id,
      name: currentUser!.name,
      email: currentUser!.email,
      monthlyIncome: income,
    );

    // update list entry too
    final idx = _users.indexWhere((u) => u.id == currentUser!.id);
    if (idx != -1) {
      _users[idx] = updated;
    }

    currentUser = updated;
    notifyListeners();
  }

  // ---------- LOGOUT ----------
  void logout() {
    currentUser = null;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return email.contains("@") && email.contains(".");
  }
}
