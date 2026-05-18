// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class ProfileService {
//   final supabase = Supabase.instance.client;
//
//   Future<Map<String, dynamic>?> getUserProfile(String userId) async {
//     final response = await supabase
//         .from('profiles')
//         .select()
//         .eq('id', userId)
//         .single();
//
//     final email = Supabase.instance.client.auth.currentUser?.email;
//
//
//     return {
//       "full_name" : response["full_name"],
//       "email": email,
//       "avatar_url": response["avatar_url"],
//       // "phone": response["phone"],
//       // "address": response["address"],
//     }; // returns map: { full_name: "...", email: "...", ... }
//   }
//
//   Future<void> updateUserProfile(
//       String userId, String name, String? avatarUrl) async {
//     await supabase.from('profiles').update({
//       'full_name': name,
//       if (avatarUrl != null) 'avatar_url': avatarUrl,
//     }).eq('id', userId);
//   }
//
// }

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _client.from('profiles').upsert({
      'id': userId,
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Returns a 0.0–1.0 completeness score based on filled fields.
  double profileCompleteness(Map<String, dynamic>? profile) {
    if (profile == null) return 0;
    const fields = [
      'full_name',
      'phone',
      'address',
      'date_of_birth',
      'gender',
      'blood_group',
      'allergies',
      'medical_conditions',
      'medications',
      'weight_kg',
      'height_cm',
      'emergency_contact_name',
      'emergency_contact_phone',
      'emergency_contact_relation',
    ];
    final filled =
        fields.where((f) => profile[f] != null && profile[f].toString().isNotEmpty).length;
    return filled / fields.length;
  }

  bool isProfileComplete(Map<String, dynamic>? profile) =>
      profileCompleteness(profile) >= 1.0;
}