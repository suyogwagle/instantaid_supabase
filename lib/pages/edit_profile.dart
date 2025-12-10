// import 'package:flutter/material.dart';
// import 'package:instant_aid/models/user_model.dart';
// import 'package:instant_aid/services/profile_service.dart';
// import 'package:instant_aid/widget/user_image.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   final UserModel user;
//   const EditProfileScreen({super.key, required this.user});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//
//   Map<String, dynamic>? profile;
//   bool loading = true;
//   String? _imageUrl;
//
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }
//
//   @override
//   void dispose(){
//     _nameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadProfile() async {
//     final data = await ProfileService().getUserProfile(widget.user.id);
//     setState(() {
//       profile = data;
//       loading = false;
//       _nameController.text = data?['full_name'] ?? "";
//       _emailController.text = data?['email'] ?? "";
//       _imageUrl = data?['avatar_url'];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: false,
//         elevation: 0,
//         backgroundColor: const Color(0xff0043ba),
//         foregroundColor: Colors.white,
//         title: const Text("Edit Profile"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           children: [
//             UserImage(imageUrl: _imageUrl, onUpload: (imageUrl) {
//               setState(() {
//                 _imageUrl = imageUrl;
//               });
//             }),
//             const Divider(),
//             Form(
//               child: Column(
//                 children: [
//                   UserInfoEditField(
//                     text: "Name",
//                     child: TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: const Color(0xFF006DBF).withValues(alpha: 0.1),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16.0 * 1.5, vertical: 16.0),
//                         border: const OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                           borderRadius: BorderRadius.all(Radius.circular(50)),
//                         ),
//                       ),
//                     ),
//                   ),
//                   UserInfoEditField(
//                     text: "Email",
//                     child: TextFormField(
//                       controller: _emailController,
//                       readOnly: true,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: const Color(0xFF006DBF).withValues(alpha: 0.1),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16.0 * 1.5, vertical: 16.0),
//                         border: const OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                           borderRadius: BorderRadius.all(Radius.circular(50)),
//                         ),
//                       ),
//                     ),
//                   ),
//                   UserInfoEditField(
//                     text: "Phone",
//                     child: TextFormField(
//                       initialValue: "(316) 555-0116",
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: const Color(0xFF006DBF).withValues(alpha: 0.1),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16.0 * 1.5, vertical: 16.0),
//                         border: const OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                           borderRadius: BorderRadius.all(Radius.circular(50)),
//                         ),
//                       ),
//                     ),
//                   ),
//                   UserInfoEditField(
//                     text: "Address",
//                     child: TextFormField(
//                       initialValue: "New York, NVC",
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: const Color(0xFF006DBF).withValues(alpha: 0.1),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16.0 * 1.5, vertical: 16.0),
//                         border: const OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                           borderRadius: BorderRadius.all(Radius.circular(50)),
//                         ),
//                       ),
//                     ),
//                   ),
//                   UserInfoEditField(
//                     text: "Old Password",
//                     child: TextFormField(
//                       obscureText: true,
//                       initialValue: "demopass",
//                       decoration: InputDecoration(
//                         suffixIcon: const Icon(
//                           Icons.visibility_off,
//                           size: 20,
//                         ),
//                         filled: true,
//                         fillColor: const Color(0xFF006DBF).withValues(alpha: 0.1),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16.0 * 1.5, vertical: 16.0),
//                         border: const OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                           borderRadius: BorderRadius.all(Radius.circular(50)),
//                         ),
//                       ),
//                     ),
//                   ),
//                   UserInfoEditField(
//                     text: "New Password",
//                     child: TextFormField(
//                       decoration: InputDecoration(
//                         hintText: "New Password",
//                         filled: true,
//                         fillColor: const Color(0xFF006DBF).withValues(alpha: 0.1),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16.0 * 1.5, vertical: 16.0),
//                         border: const OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                           borderRadius: BorderRadius.all(Radius.circular(50)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 SizedBox(
//                   width: screenWidth*0.35,
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context)
//                           .textTheme
//                           .bodyLarge!
//                           .color!
//                           .withValues(alpha: 0.08),
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 48),
//                       shape: const StadiumBorder(),
//                     ),
//                     child: const Text("Cancel"),
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 SizedBox(
//                   width: screenWidth*0.5,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xff0043ba),
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 48),
//                       shape: const StadiumBorder(),
//                     ),
//                       onPressed: () async {
//                         try {
//                           await ProfileService().updateUserProfile(
//                             widget.user.id,
//                             _nameController.text.trim(),
//                             _imageUrl,
//                           );
//
//                           widget.user.fullName = _nameController.text.trim();
//                           widget.user.avatarUrl = _imageUrl;
//
//                           if (mounted) Navigator.pop(context, true);
//                         } catch (e) {
//                           print("ERROR SAVING PROFILE: $e");
//                         }
//                       },
//                     child: const Text("Save Update"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // class ProfilePic extends StatelessWidget {
// //   const ProfilePic({
// //     super.key,
// //     required this.image,
// //     this.isShowPhotoUpload = false,
// //     this.imageUploadBtnPress,
// //   });
// //
// //   final String image;
// //   final bool isShowPhotoUpload;
// //   final VoidCallback? imageUploadBtnPress;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(16.0),
// //       margin: const EdgeInsets.symmetric(vertical: 16.0),
// //       decoration: BoxDecoration(
// //         shape: BoxShape.circle,
// //         border: Border.all(
// //           color:
// //           Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.08),
// //         ),
// //       ),
// //       child: Stack(
// //         alignment: Alignment.bottomRight,
// //         children: [
// //           CircleAvatar(
// //             radius: 50,
// //             backgroundImage: NetworkImage(image),
// //           ),
// //           InkWell(
// //             onTap: imageUploadBtnPress,
// //             child: CircleAvatar(
// //               radius: 13,
// //               backgroundColor: Theme.of(context).primaryColor,
// //               child: const Icon(
// //                 Icons.add,
// //                 color: Colors.white,
// //                 size: 20,
// //               ),
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// class UserInfoEditField extends StatelessWidget {
//   const UserInfoEditField({
//     super.key,
//     required this.text,
//     required this.child,
//   });
//
//   final String text;
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16.0 / 2),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(text),
//           ),
//           Expanded(
//             flex: 3,
//             child: child,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:instant_aid/models/user_model.dart';
import 'package:instant_aid/services/profile_service.dart';
import 'package:instant_aid/widget/user_image.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;
  String? _imageUrl;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final data = await ProfileService().getUserProfile(widget.user.id);

    setState(() {
      profile = data;
      loading = false;

      _nameController.text = data?['full_name'] ?? "";
      _emailController.text = data?['email'] ?? "";
      _imageUrl = data?['avatar_url'];
    });
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF006DBF).withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xff0043ba),
        foregroundColor: Colors.white,
        title: const Text("Edit Profile"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            //Profile Image
            UserImage(
              imageUrl: _imageUrl,
              onUpload: (imageUrl) {
                setState(() {
                  _imageUrl = imageUrl;
                });
              },
            ),

            const SizedBox(height: 8),
            const Divider(),

            //Form Fields
            Form(
              child: Column(
                children: [
                  UserInfoEditField(
                    text: "Name",
                    child: TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(),
                    ),
                  ),

                  UserInfoEditField(
                    text: "Email",
                    child: TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: _inputDecoration(),
                    ),
                  ),

                  UserInfoEditField(
                    text: "Phone",
                    child: TextFormField(
                      initialValue: profile?['phone'] ?? "",
                      decoration: _inputDecoration(hint: "Enter phone number"),
                    ),
                  ),

                  UserInfoEditField(
                    text: "Address",
                    child: TextFormField(
                      initialValue: profile?['address'] ?? "",
                      decoration: _inputDecoration(hint: "Enter address"),
                    ),
                  ),

                  //Old Password
                  UserInfoEditField(
                    text: "Old Password",
                    child: TextFormField(
                      obscureText: true,
                      decoration: _inputDecoration().copyWith(
                        suffixIcon: const Icon(Icons.visibility_off, size: 20),
                      ),
                    ),
                  ),

                  //New Password
                  UserInfoEditField(
                    text: "New Password",
                    child: TextFormField(
                      obscureText: true,
                      decoration: _inputDecoration(hint: "New Password"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            //Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: screenWidth * 0.35,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: screenWidth * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0043ba),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () async {
                      try {
                        await ProfileService().updateUserProfile(
                          widget.user.id,
                          _nameController.text.trim(),
                          _imageUrl,
                        );

                        widget.user.fullName = _nameController.text.trim();
                        widget.user.avatarUrl = _imageUrl;

                        if (mounted) Navigator.pop(context, true);
                      } catch (e) {
                        print("ERROR SAVING PROFILE: $e");
                      }
                    },
                    child: const Text("Save Update"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//Reusable Field Label
class UserInfoEditField extends StatelessWidget {
  final String text;
  final Widget child;

  const UserInfoEditField({
    super.key,
    required this.text,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 3, child: child),
        ],
      ),
    );
  }
}
