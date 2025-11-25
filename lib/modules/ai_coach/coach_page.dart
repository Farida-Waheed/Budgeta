import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/colors.dart';
import 'ai_coach_controller.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AiCoachController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Coach"),
      ),
      body: Column(
        children: [
          // messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.messages.length,
              itemBuilder: (_, index) {
                final msg = controller.messages[index];
                final isUser = msg.startsWith("You:");

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.pink.withValues(alpha: 0.2)
                          : AppColors.rose.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),

          // message input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: "Ask your coach...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.red),
                onPressed: () {
                  if (textController.text.isEmpty) return;
                  controller.sendMessage(textController.text);
                  textController.clear();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
