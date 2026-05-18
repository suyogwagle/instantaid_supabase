import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarService {
  final _client = Supabase.instance.client;
  final _picker = ImagePicker();

  static const _bucket = 'avatars';

  /// Opens the image picker and returns the picked file, or null if cancelled.
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    return _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
  }

  /// Uploads [file] to Supabase Storage, saves the clean URL to profiles,
  /// and returns a cache-busted URL for immediate display.
  Future<String> uploadAndSave(String userId, XFile file) async {
    // Read bytes directly from XFile — works on all platforms including
    // Android where file.path may be a content:// URI not a real FS path
    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) throw Exception('Selected file is empty.');

    // Use the actual file extension so content-type is correct
    final ext = file.name.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final storagePath = '$userId/avatar.$ext';

    // Upload — upsert:true overwrites any existing file at the same path
    await _client.storage.from(_bucket).uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: true,
      ),
    );

    // Clean public URL — no query params, safe to store in DB
    final cleanUrl =
    _client.storage.from(_bucket).getPublicUrl(storagePath);

    // Persist to profiles table
    await _client
        .from('profiles')
        .update({
      'avatar_url': cleanUrl,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', userId);

    // Return cache-busted URL so Flutter re-fetches instead of using
    // its in-memory cache of the old image
    return '$cleanUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Removes the avatar file from Storage and clears avatar_url in profiles.
  Future<void> deleteAvatar(String userId) async {
    // Try both common extensions
    try {
      await _client.storage
          .from(_bucket)
          .remove(['$userId/avatar.jpg', '$userId/avatar.png']);
    } catch (_) {}

    await _client
        .from('profiles')
        .update({
      'avatar_url': null,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', userId);
  }
}