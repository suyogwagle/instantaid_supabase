import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instant_aid/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class UserImage extends StatelessWidget {
  const UserImage({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  final String? imageUrl;
  final void Function(String imageUrl) onUpload;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: imageUrl != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl!, fit: BoxFit.cover),
          )
              : Container(
            color: Colors.grey[300],
            child: const Center(child: Text('No image')),
          ),
        ),
        SizedBox(height: 12),

        ElevatedButton(onPressed: () async {
          final ImagePicker picker = ImagePicker(); // Pick an image.
          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
          if (image == null) return;
          final imageExtension = image.path.split('.').last.toLowerCase();//there is a better way to do this
          final imageBytes = await image.readAsBytes();
          final userId = supabase.auth.currentUser!.id;
          final fileName = 'profile.$imageExtension';
          final imagePath = '$userId/$fileName';
          await supabase.storage
              .from('profile_pictures').
                uploadBinary(
                  imagePath,
                  imageBytes,
                  fileOptions: FileOptions(
                    upsert: true,
                    contentType: 'image/$imageExtension'
                  ));
          String imageUrl =
          supabase.storage.from('profile_pictures').getPublicUrl(imagePath);
          onUpload(imageUrl);
        },
            child: const Text('Upload'))
      ],
    );
  }
}
