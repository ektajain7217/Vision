import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const ChatInput({
    Key? key,
    required this.controller,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Type a message...',
        filled: true,
        fillColor: AppTheme.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: AppTheme.primaryColor,
          ),
          onPressed: () {
            final text = controller.text;
            if (text.trim().isNotEmpty) {
              onSubmitted(text);
              controller.clear();
            }
          },
        ),
      ),
      minLines: 1,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      onSubmitted: (text) {
        if (text.trim().isNotEmpty) {
          onSubmitted(text);
          controller.clear();
        }
      },
    );
  }
}