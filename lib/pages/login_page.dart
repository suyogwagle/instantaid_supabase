import 'package:flutter/material.dart';
import 'package:instant_aid/main.dart';
import 'package:instant_aid/models/user_model.dart';
import 'package:instant_aid/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (isLogin) {
        // LOGIN
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final user = response.user;
        if (user == null) throw AuthException("User not found");

        // Fetch profile data
        final profile = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile not found.")),
          );
          return;
        }

        final userModel = UserModel.fromMap(profile);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: userModel)),
        );

      } else {
        // REGISTER
        final name = _nameController.text.trim();

        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name}, // Trigger inserts into profiles
          emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
        );

        final user = response.user;
        if (user == null) throw AuthException("Registration failed");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful. Verify your email.")),
        );

        setState(() {
          isLogin = true;
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
        });
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auth error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your email first")),
      );
      return;
    }
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutterquickstart://reset-callback/',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? "Login" : "Register"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!isLogin)
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty ? "Enter your name" : null,
                        ),
                      if (!isLogin) const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || !value.contains('@')
                            ? "Enter a valid email"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                      ),
                      if (isLogin)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _resetPassword,
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      const SizedBox(height: 24),
                      isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _authenticate,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(isLogin ? "Login" : "Register"),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => isLogin = !isLogin),
                        child: Text(isLogin
                            ? "Don’t have an account? Register"
                            : "Already have an account? Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

