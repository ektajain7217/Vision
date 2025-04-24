import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/chat_session.dart';
import '../services/groq_service.dart';
import '../services/storage_service.dart';
import '../services/voice_service.dart';

class ChatProvider extends ChangeNotifier {
  final GroqService _groqService;
  final StorageService _storageService;
  final VoiceService _voiceService;
  
  ChatSession? _currentSession;
  List<ChatSession> _sessions = [];
  bool _isLoading = false;
  bool _isListening = false;
  
  ChatProvider({
    required GroqService groqService,
    required StorageService storageService,
    required VoiceService voiceService,
  }) : 
    _groqService = groqService,
    _storageService = storageService,
    _voiceService = voiceService {
    _initProvider();
  }
  
  Future<void> _initProvider() async {
    _sessions = await _storageService.getSessions();
    if (_sessions.isNotEmpty) {
      _currentSession = _sessions.first;
    }
    notifyListeners();
  }
  
  ChatSession? get currentSession => _currentSession;
  List<ChatSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  
  Future<void> createNewSession() async {
    final newSession = ChatSession(
      id: const Uuid().v4(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      messages: [],
    );
    
    _sessions.insert(0, newSession);
    _currentSession = newSession;
    await _storageService.saveSession(newSession);
    notifyListeners();
  }
  
  Future<void> selectSession(String sessionId) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    _currentSession = session;
    notifyListeners();
  }
  
  Future<void> deleteSession(String sessionId) async {
    await _storageService.deleteSession(sessionId);
    _sessions.removeWhere((s) => s.id == sessionId);
    
    if (_currentSession?.id == sessionId) {
      _currentSession = _sessions.isNotEmpty ? _sessions.first : null;
    }
    
    notifyListeners();
  }
  
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty || _currentSession == null) return;
    
    final userMessage = Message(
      id: const Uuid().v4(),
      content: text,
      type: MessageType.text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    
    _addMessage(userMessage);
    await _getAIResponse();
  }
  
  Future<void> sendVoiceMessage(String text) async {
    if (text.trim().isEmpty || _currentSession == null) return;
    
    final userMessage = Message(
      id: const Uuid().v4(),
      content: text,
      type: MessageType.voice,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    
    _addMessage(userMessage);
    await _getAIResponse(speakResponse: true);
  }
  
  Future<void> sendDocumentMessage(File file) async {
    if (_currentSession == null) return;
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = file.path.split('/').last;
    final savedFile = await file.copy('${directory.path}/$fileName');
    
    final userMessage = Message(
      id: const Uuid().v4(),
      content: 'Sent a document: $fileName',
      type: MessageType.document,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      documentName: fileName,
      documentPath: savedFile.path,
    );
    
    _addMessage(userMessage);
    
    // For simplicity, we're just acknowledging the document
    final botMessage = Message(
      id: const Uuid().v4(),
      content: 'I received your document: $fileName. What would you like me to do with it?',
      type: MessageType.text,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
    );
    
    _addMessage(botMessage);
  }
  
  Future<void> startVoiceRecording() async {
    if (_currentSession == null) return;
    
    _isListening = await _voiceService.startListening((text) {
      sendVoiceMessage(text);
      _isListening = false;
      notifyListeners();
    });
    
    notifyListeners();
  }
  
  Future<void> stopVoiceRecording() async {
    await _voiceService.stopListening();
    _isListening = false;
    notifyListeners();
  }
  
  void _addMessage(Message message) {
    if (_currentSession == null) return;
    
    _currentSession!.messages.add(message);
    
    // Update session title if it's the first message
    if (_currentSession!.messages.length == 1 && message.sender == MessageSender.user) {
      final newTitle = message.content.length > 30 
          ? '${message.content.substring(0, 27)}...' 
          : message.content;
      
      _currentSession = ChatSession(
        id: _currentSession!.id,
        title: newTitle,
        createdAt: _currentSession!.createdAt,
        messages: _currentSession!.messages,
      );
    }
    
    _storageService.saveSession(_currentSession!);
    notifyListeners();
  }
  
  Future<void> _getAIResponse({bool speakResponse = false}) async {
    if (_currentSession == null || _currentSession!.messages.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final messages = _currentSession!.messages
          .map((msg) => {
            'role': msg.sender == MessageSender.user ? 'user' : 'assistant',
            'content': msg.content,
          })
          .toList();
      
      final response = await _groqService.generateResponse(messages);
      
      final botMessage = Message(
        id: const Uuid().v4(),
        content: response,
        type: MessageType.text,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      );
      
      _addMessage(botMessage);
      
      if (speakResponse) {
        await _voiceService.speak(response);
      }
    } catch (e) {
      // Use a logger instead of print in production
      debugPrint('Error getting AI response: $e');
      
      final errorMessage = Message(
        id: const Uuid().v4(),
        content: 'Sorry, I encountered an error. Please try again.',
        type: MessageType.text,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      );
      
      _addMessage(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}