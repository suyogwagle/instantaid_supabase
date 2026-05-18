import 'package:flutter/material.dart';
import 'package:instant_aid/services/progress_service.dart';
import 'package:instant_aid/services/quiz_service.dart';
import 'package:provider/provider.dart';
import 'package:instant_aid/config/constants.dart';
import 'package:instant_aid/pages/homepage.dart';
import 'package:instant_aid/models/user_model.dart';
import 'package:instant_aid/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:instant_aid/services/injury_classifier.dart';
import 'package:instant_aid/services/whisper_service.dart';
import 'package:instant_aid/services/hybrid_intent_classifier.dart';
import 'package:app_links/app_links.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      detectSessionInUri: true,
    ),
  );

  // Handle deep link when app is already open and email link is clicked
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) {
    if (uri.toString().contains('login-callback')) {
      Supabase.instance.client.auth.getSessionFromUrl(uri);
    }
  });

  // Handle deep link when app was fully closed and opened via email link
  final initialUri = await appLinks.getInitialLink();
  if (initialUri != null &&
      initialUri.toString().contains('login-callback')) {
    await Supabase.instance.client.auth.getSessionFromUrl(initialUri);
  }

  supabase.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    if (event == AuthChangeEvent.signedOut) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }
    if (event == AuthChangeEvent.signedIn) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
    }
  });

  debugPrint("🔄 Loading AI models...");
  final classifier = InjuryClassifier();
  await classifier.loadModel();
  debugPrint("✅ InjuryClassifier loaded");

  final hybridClassifier = HybridIntentClassifier(classifier);
  debugPrint("✅ HybridIntentClassifier ready");

  final whisper = WhisperService();
  await whisper.initModel();
  debugPrint("✅ WhisperService loaded");

  runApp(
    MultiProvider(
      providers: [
        Provider<QuizService>(
          create: (_) => QuizService(Supabase.instance.client),
        ),
        Provider<ProgressService>(
          create: (_) => ProgressService(Supabase.instance.client),
        ),
      ],
      child: MyApp(
        classifier: classifier,
        hybridClassifier: hybridClassifier,
        whisper: whisper,
      ),
    ),
  );
}

final supabase = Supabase.instance.client;

// Converted to StatefulWidget to support WidgetsBindingObserver
class MyApp extends StatefulWidget {
  final InjuryClassifier classifier;
  final HybridIntentClassifier hybridClassifier;
  final WhisperService whisper;

  const MyApp({
    super.key,
    required this.classifier,
    required this.hybridClassifier,
    required this.whisper,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App is being killed — sign out automatically
      Supabase.instance.client.auth.signOut();
    }
  }

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
        '/login': (context) => LoginPage(
          classifier: widget.classifier,
          whisper: widget.whisper,
          hybridClassifier: widget.hybridClassifier,
        ),
        '/home': (context) {
          return FutureBuilder<UserModel?>(
            future: _getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData) {
                return LoginPage(
                  classifier: widget.classifier,
                  whisper: widget.whisper,
                  hybridClassifier: widget.hybridClassifier,
                );
              }
              return HomePage(user: snapshot.data!, hybridClassifier: widget.hybridClassifier);
            },
          );
        },
      },

      home: FutureBuilder<UserModel?>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (!snapshot.hasData) {
            return LoginPage(
              classifier: widget.classifier,
              whisper: widget.whisper,
              hybridClassifier: widget.hybridClassifier,
            );
          }
          return HomePage(user: snapshot.data!, hybridClassifier: widget.hybridClassifier);
        },
      ),
    );
  }
}