enum MessageType { text, voice, document }
enum MessageSender { user, bot }

class Message {
  final String id;
  final String content;
  final MessageType type;
  final MessageSender sender;
  final DateTime timestamp;
  final String? documentName;
  final String? documentPath;

  Message({
    required this.id,
    required this.content,
    required this.type,
    required this.sender,
    required this.timestamp,
    this.documentName,
    this.documentPath,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.byName(json['type']),
      sender: MessageSender.values.byName(json['sender']),
      timestamp: DateTime.parse(json['timestamp']),
      documentName: json['documentName'],
      documentPath: json['documentPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'documentName': documentName,
      'documentPath': documentPath,
    };
  }
}