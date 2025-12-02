import 'package:flutter/material.dart';
import 'package:instant_aid/config/constants.dart';
import 'package:instant_aid/homepage.dart';
import 'package:instant_aid/models/user_model.dart';
import 'package:instant_aid/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:instant_aid/services/injury_classifier.dart';
import 'package:instant_aid/services/whisper_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Preload classifier once
  final classifier = InjuryClassifier();
  await classifier.loadModel();

  // Preload Whisper offline model once
  final whisper = WhisperService();
  await whisper.initModel();

  runApp(MyApp(classifier: classifier, whisper: whisper));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  final InjuryClassifier classifier;
  final WhisperService whisper;

  const MyApp({super.key, required this.classifier, required this.whisper});

  Future<UserModel?> _getCurrentUser() async {
    final session = supabase.auth.currentSession;
    if (session == null) return null;

    final userId = session.user.id;
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstantAID Auth',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<UserModel?>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData) {
            // Pass classifier + whisper into LoginPage
            return LoginPage(classifier: classifier, whisper: whisper);
          }
          // Pass whisper into HomePage too if needed
          return HomePage(user: snapshot.data!);
        },
      ),
    );
  }
}
