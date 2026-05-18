// class UserModel {
//   final String id;
//   final DateTime? updatedAt;
//   final String? username;
//    String? fullName;
//   final String? email;
//    String? avatarUrl;
//
//   UserModel({
//     required this.id,
//     required this.email,
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
//       email: map['email'] as String?,
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
//       'email': email,
//       'avatar_url': avatarUrl,
//     };
//   }
//
//   UserModel copyWith({
//     String? id,
//     DateTime? updatedAt,
//     String? username,
//     String? fullName,
//     String? email,
//     String? avatarUrl,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       updatedAt: updatedAt ?? this.updatedAt,
//       username: username ?? this.username,
//       fullName: fullName ?? this.fullName,
//       email: email?? this.email,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//     );
//   }
// }
//
//


class UserModel {
  final String id;
  final DateTime? updatedAt;
  final String? username;
  String? fullName;
  final String? email;
  String? avatarUrl;

  // ── Personal info
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  final String? address;

  // ── Medical info
  final String? bloodGroup;
  final String? allergies;
  final String? medicalConditions;
  final String? medications;
  final double? weightKg;
  final double? heightCm;

  // ── Emergency contact
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;

  // ── Stats
  final int sosCount;
  final int guidesUsed;

  UserModel({
    required this.id,
    required this.email,
    this.updatedAt,
    this.username,
    this.fullName,
    this.avatarUrl,
    // Personal
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.address,
    // Medical
    this.bloodGroup,
    this.allergies,
    this.medicalConditions,
    this.medications,
    this.weightKg,
    this.heightCm,
    // Emergency contact
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    // Stats
    this.sosCount = 0,
    this.guidesUsed = 0,
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
      // Personal
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'] as String)
          : null,
      gender: map['gender'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      // Medical
      bloodGroup: map['blood_group'] as String?,
      allergies: map['allergies'] as String?,
      medicalConditions: map['medical_conditions'] as String?,
      medications: map['medications'] as String?,
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      heightCm: (map['height_cm'] as num?)?.toDouble(),
      // Emergency contact
      emergencyContactName: map['emergency_contact_name'] as String?,
      emergencyContactPhone: map['emergency_contact_phone'] as String?,
      emergencyContactRelation: map['emergency_contact_relation'] as String?,
      // Stats
      sosCount: (map['sos_count'] as int?) ?? 0,
      guidesUsed: (map['guides_used'] as int?) ?? 0,
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
      // Personal
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'address': address,
      // Medical
      'blood_group': bloodGroup,
      'allergies': allergies,
      'medical_conditions': medicalConditions,
      'medications': medications,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      // Emergency contact
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      // Stats
      'sos_count': sosCount,
      'guides_used': guidesUsed,
    };
  }

  UserModel copyWith({
    String? id,
    DateTime? updatedAt,
    String? username,
    String? fullName,
    String? email,
    String? avatarUrl,
    // Personal
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? address,
    // Medical
    String? bloodGroup,
    String? allergies,
    String? medicalConditions,
    String? medications,
    double? weightKg,
    double? heightCm,
    // Emergency contact
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    // Stats
    int? sosCount,
    int? guidesUsed,
  }) {
    return UserModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      // Personal
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      // Medical
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      // Emergency contact
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation:
      emergencyContactRelation ?? this.emergencyContactRelation,
      // Stats
      sosCount: sosCount ?? this.sosCount,
      guidesUsed: guidesUsed ?? this.guidesUsed,
    );
  }
}