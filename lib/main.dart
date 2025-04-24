import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'providers/chat_provider.dart';
import 'services/groq_service.dart';
import 'services/storage_service.dart';
import 'services/voice_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize voice service
  final voiceService = VoiceService();
  await voiceService.initSpeech();
  
  runApp(MyApp(voiceService: voiceService));
}

class MyApp extends StatelessWidget {
  final VoiceService voiceService;
  
  const MyApp({
    super.key,
    required this.voiceService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            groqService: GroqService(),
            storageService: StorageService(),
            voiceService: voiceService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AI Assistant',
        theme: AppTheme.darkTheme(),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
