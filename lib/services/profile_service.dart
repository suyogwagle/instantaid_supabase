import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    final email = Supabase.instance.client.auth.currentUser?.email;


    return {
      "full_name" : response["full_name"],
      "email": email,
      "avatar_url": response["avatar_url"],
      // "phone": response["phone"],
      // "address": response["address"],
    }; // returns map: { full_name: "...", email: "...", ... }
  }

  Future<void> updateUserProfile(
      String userId, String name, String? avatarUrl) async {
    await supabase.from('profiles').update({
      'full_name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    }).eq('id', userId);
  }

}