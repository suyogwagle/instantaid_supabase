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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _imageUrl;
  String? _errorMessage;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService().getUserProfile(widget.user.id);

      if (mounted) {
        setState(() {
          _profile = data;
          _isLoading = false;
          _nameController.text = data?['full_name'] ?? "";
          _emailController.text = data?['email'] ?? "";
          _phoneController.text = data?['phone'] ?? "";
          _addressController.text = data?['address'] ?? "";
          _imageUrl = data?['avatar_url'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await ProfileService().updateUserProfile(
        widget.user.id,
        _nameController.text.trim(),
        _imageUrl,
        // phone: _phoneController.text.trim(),
        // address: _addressController.text.trim(),
      );

      // Update user model
      widget.user.fullName = _nameController.text.trim();
      widget.user.avatarUrl = _imageUrl;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF006DBF).withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 22.0,
        vertical: 16.0,
      ),
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(50),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      // Basic phone validation - adjust regex based on your requirements
      final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Invalid phone number';
      }
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (_oldPasswordController.text.isNotEmpty &&
        (value == null || value.isEmpty)) {
      return 'Enter new password';
    }
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Profile"),
          backgroundColor: const Color(0xff0043ba),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadProfile();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xff0043ba),
        foregroundColor: Colors.white,
        title: const Text("Edit Profile"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Image
                  UserImage(
                    imageUrl: _imageUrl,
                    onUpload: (imageUrl) {
                      setState(() => _imageUrl = imageUrl);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Form Fields
                  _FormSection(
                    title: "Personal Information",
                    children: [
                      _UserInfoEditField(
                        label: "Name",
                        isRequired: true,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(hint: "Enter your name"),
                          validator: _validateName,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      _UserInfoEditField(
                        label: "Email",
                        child: TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: _inputDecoration(),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      _UserInfoEditField(
                        label: "Phone",
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: _inputDecoration(
                            hint: "Enter phone number",
                          ),
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      _UserInfoEditField(
                        label: "Address",
                        child: TextFormField(
                          controller: _addressController,
                          decoration: _inputDecoration(hint: "Enter address"),
                          maxLines: 2,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Password Section
                  _FormSection(
                    title: "Change Password (Optional)",
                    children: [
                      _UserInfoEditField(
                        label: "Old Password",
                        child: TextFormField(
                          controller: _oldPasswordController,
                          obscureText: _obscureOldPassword,
                          decoration: _inputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureOldPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureOldPassword = !_obscureOldPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      _UserInfoEditField(
                        label: "New Password",
                        child: TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: _inputDecoration(
                            hint: "Enter new password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                          validator: _validateNewPassword,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(
                              color: Colors.black.withOpacity(0.3),
                            ),
                            shape: const StadiumBorder(),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0043ba),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            minimumSize: const Size(double.infinity, 48),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                              : const Text("Save Changes"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff0043ba),
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _UserInfoEditField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isRequired;

  const _UserInfoEditField({
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isRequired)
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: child,
          ),
        ],
      ),
    );
  }
}
