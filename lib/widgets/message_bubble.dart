import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final formatter = DateFormat('h:mm a');
    final formattedTime = formatter.format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(0) : null,
                      bottomLeft: !isUser ? const Radius.circular(0) : null,
                    ),
                  ),
                  child: _buildMessageContent(context),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.type == MessageType.voice)
                      const Icon(
                        Icons.mic,
                        size: 12,
                        color: AppTheme.subtleTextColor,
                      ),
                    if (message.type == MessageType.voice)
                      const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.subtleTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isUser) _buildAvatar(isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        isUser ? Icons.person_outline : Icons.smart_toy_outlined,
        color: isUser ? Colors.white : AppTheme.primaryColor,
        size: 20,
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return message.sender == MessageSender.bot
            ? MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: message.sender == MessageSender.user
                        ? Colors.white
                        : AppTheme.textColor,
                  ),
                  code: const TextStyle(
                    backgroundColor: Color(0xFF3D3D3D),
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: const Color(0xFF3D3D3D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : Text(
                message.content,
                style: TextStyle(
                  color: message.sender == MessageSender.user
                      ? Colors.white
                      : AppTheme.textColor,
                ),
              );
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.volume_up,
              size: 16,
              color: message.sender == MessageSender.user
                  ? Colors.white
                  : AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.sender == MessageSender.user
                      ? Colors.white
                      : AppTheme.textColor,
                ),
              ),
            ),
          ],
        );
      case MessageType.document:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description,
                  size: 20,
                  color: message.sender == MessageSender.user
                      ? Colors.white
                      : AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.documentName ?? 'Document',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: message.sender == MessageSender.user
                          ? Colors.white
                          : AppTheme.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.content,
              style: TextStyle(
                color: message.sender == MessageSender.user
                    ? Colors.white
                    : AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            if (message.documentPath != null)
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Open document
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Open'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: message.sender == MessageSender.user
                      ? Colors.white.withOpacity(0.2)
                      : AppTheme.primaryColor.withOpacity(0.2),
                  foregroundColor: message.sender == MessageSender.user
                      ? Colors.white
                      : AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 0),
                ),
              ),
          ],
        );
    }
  }
}