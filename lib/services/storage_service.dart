import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';
import '../models/message.dart';

class StorageService {
  static const String _sessionsKey = 'chat_sessions';

  Future<List<ChatSession>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString(_sessionsKey);
    
    if (sessionsJson == null) {
      return [];
    }
    
    List<dynamic> sessionsList = jsonDecode(sessionsJson);
    return sessionsList.map((json) => ChatSession.fromJson(json)).toList();
  }

  Future<void> saveSession(ChatSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ChatSession> sessions = await getSessions();
    
    final existingIndex = sessions.indexWhere((s) => s.id == session.id);
    if (existingIndex >= 0) {
      sessions[existingIndex] = session;
    } else {
      sessions.add(session);
    }
    
    final List<Map<String, dynamic>> sessionsJson = 
        sessions.map((session) => session.toJson()).toList();
    
    await prefs.setString(_sessionsKey, jsonEncode(sessionsJson));
  }

  Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ChatSession> sessions = await getSessions();
    
    sessions.removeWhere((session) => session.id == sessionId);
    
    final List<Map<String, dynamic>> sessionsJson = 
        sessions.map((session) => session.toJson()).toList();
    
    await prefs.setString(_sessionsKey, jsonEncode(sessionsJson));
  }
}