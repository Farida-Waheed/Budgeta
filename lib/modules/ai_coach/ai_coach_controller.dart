import 'package:flutter/material.dart';

class AiCoachController extends ChangeNotifier {
  final List<String> messages = [
    "Hi! I'm your Budgeta coach. Ready to take control of your money?",
  ];

  void sendMessage(String msg) {
    messages.add("You: $msg");

    // fake AI response for now
    Future.delayed(const Duration(milliseconds: 500), () {
      messages.add(_generateFakeAiResponse(msg));
      notifyListeners();
    });

    notifyListeners();
  }

  String _generateFakeAiResponse(String msg) {
    if (msg.contains("save")) {
      return "Try setting aside 10% of your weekly income. Small steps make a huge difference!";
    }

    if (msg.contains("spend")) {
      return "Track every purchase for 3 days. Awareness is your first superpower!";
    }

    return "Great! Keep going — your future self will thank you.";
  }
}
