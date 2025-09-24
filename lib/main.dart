import 'package:flutter/material.dart';
import 'package:instant_aid/config/constants.dart';
import 'package:instant_aid/homepage.dart';
import 'package:instant_aid/models/user_model.dart';
import 'package:instant_aid/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            return const LoginPage();
          }
          return HomePage(user: snapshot.data!);
        },
      ),
    );
  }
}
