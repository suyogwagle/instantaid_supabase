// class UserModel {
//   final String id;
//   final DateTime? updatedAt;
//   final String? username;
//   final String? fullName;
//   final String? avatarUrl;
//
//   UserModel({
//     required this.id,
//     this.updatedAt,
//     this.username,
//     this.fullName,
//     this.avatarUrl,
//   });
//
//   factory UserModel.fromMap(Map<String, dynamic> map) {
//     return UserModel(
//       id: map['id'] as String,
//       updatedAt: map['updated_at'] != null
//           ? DateTime.parse(map['updated_at'] as String)
//           : null,
//       username: map['username'] as String?,
//       fullName: map['full_name'] as String?,
//       avatarUrl: map['avatar_url'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'updated_at': updatedAt?.toIso8601String(),
//       'username': username,
//       'full_name': fullName,
//       'avatar_url': avatarUrl,
//     };
//   }
//
//   UserModel copyWith({
//     String? id,
//     DateTime? updatedAt,
//     String? username,
//     String? fullName,
//     String? avatarUrl,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       updatedAt: updatedAt ?? this.updatedAt,
//       username: username ?? this.username,
//       fullName: fullName ?? this.fullName,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//     );
//   }
// }
//

class UserModel {
  final String id;
  final DateTime? updatedAt;
  final String? username;
   String? fullName;
  final String? email;
   String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    this.updatedAt,
    this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      username: map['username'] as String?,
      fullName: map['full_name'] as String?,
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'updated_at': updatedAt?.toIso8601String(),
      'username': username,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }

  UserModel copyWith({
    String? id,
    DateTime? updatedAt,
    String? username,
    String? fullName,
    String? email,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}


