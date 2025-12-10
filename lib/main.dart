import 'package:flutter/material.dart';
import 'package:instant_aid/config/constants.dart';
import 'package:instant_aid/pages/homepage.dart';
import 'package:instant_aid/models/user_model.dart';
import 'package:instant_aid/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:instant_aid/services/injury_classifier.dart';
import 'package:instant_aid/services/whisper_service.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );



  supabase.auth.onAuthStateChange.listen((data) {
    final event = data.event;

    if (event == AuthChangeEvent.signedOut) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }

    if (event == AuthChangeEvent.signedIn) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
    }
  });

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
      navigatorKey: navigatorKey,

      routes: {
        '/login': (context) => LoginPage(classifier: classifier, whisper: whisper),
        '/home': (context) {
          return FutureBuilder<UserModel?>(
            future: _getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData) {
                return LoginPage(classifier: classifier, whisper: whisper);
              }
              return HomePage(user: snapshot.data!);
            },
          );
        },
      },

      home: FutureBuilder<UserModel?>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData) {
            return LoginPage(classifier: classifier, whisper: whisper);
          }
          return HomePage(user: snapshot.data!);
        },
      ),
    );
  }
}
