/// Main model class for a first aid category
import 'dart:convert';
class FirstAidCategory {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final bool isUrgent;
  final List<SubCategory> subCategories;
  final List<String> precautions;
  final List<FirstAidStep> firstAidSteps;
  final DoAndDonts doAndDonts;
  final List<Warning> warnings;
  final WhenToSeekMedicalHelp whenToSeekMedicalHelp;

  FirstAidCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.isUrgent,
    required this.subCategories,
    required this.precautions,
    required this.firstAidSteps,
    required this.doAndDonts,
    required this.warnings,
    required this.whenToSeekMedicalHelp,
  });

  factory FirstAidCategory.fromJson(Map<String, dynamic> json) {
    return FirstAidCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      isUrgent: json['isUrgent'] as bool? ?? false,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      precautions: (json['precautions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      firstAidSteps: (json['firstAidSteps'] as List<dynamic>?)
          ?.map((e) => FirstAidStep.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      doAndDonts: DoAndDonts.fromJson(
          json['doAndDonts'] as Map<String, dynamic>? ?? {}),
      warnings: (json['warnings'] as List<dynamic>?)
          ?.map((e) => Warning.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      whenToSeekMedicalHelp: WhenToSeekMedicalHelp.fromJson(
          json['whenToSeekMedicalHelp'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'isUrgent': isUrgent,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
      'precautions': precautions,
      'firstAidSteps': firstAidSteps.map((e) => e.toJson()).toList(),
      'doAndDonts': doAndDonts.toJson(),
      'warnings': warnings.map((e) => e.toJson()).toList(),
      'whenToSeekMedicalHelp': whenToSeekMedicalHelp.toJson(),
    };
  }

  @override
  String toString() {
    return 'FirstAidCategory(id: $id, name: $name, subCategories: ${subCategories.length}, steps: ${firstAidSteps.length})';
  }
}

/// Model for subcategories within a first aid category
class SubCategory {
  final String id;
  final String name;
  final String description;

  SubCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

/// Model for individual first aid steps
class FirstAidStep {
  final int stepNumber;
  final String title;
  final String instruction;
  final String? imageUrl;
  final String? videoUrl;
  final List<String>? subSteps;
  final Duration? estimatedDuration;

  FirstAidStep({
    required this.stepNumber,
    required this.title,
    required this.instruction,
    this.imageUrl,
    this.videoUrl,
    this.subSteps,
    this.estimatedDuration,
  });

  factory FirstAidStep.fromJson(Map<String, dynamic> json) {
    return FirstAidStep(
      stepNumber: json['stepNumber'] as int,
      title: json['title'] as String,
      instruction: json['instruction'] as String,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      subSteps: (json['subSteps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      estimatedDuration: json['estimatedDurationSeconds'] != null
          ? Duration(seconds: json['estimatedDurationSeconds'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'instruction': instruction,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'subSteps': subSteps,
      'estimatedDurationSeconds': estimatedDuration?.inSeconds,
    };
  }
}

/// Model for do's and don'ts
class DoAndDonts {
  final List<String> dos;
  final List<String> donts;

  DoAndDonts({
    required this.dos,
    required this.donts,
  });

  factory DoAndDonts.fromJson(Map<String, dynamic> json) {
    return DoAndDonts(
      dos: (json['dos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      donts: (json['donts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dos': dos,
      'donts': donts,
    };
  }
}

/// Model for warnings
class Warning {
  final String id;
  final String message;
  final WarningSeverity severity;
  final String? additionalInfo;

  Warning({
    required this.id,
    required this.message,
    required this.severity,
    this.additionalInfo,
  });

  factory Warning.fromJson(Map<String, dynamic> json) {
    return Warning(
      id: json['id'] as String,
      message: json['message'] as String,
      severity: WarningSeverity.fromString(json['severity'] as String? ?? 'low'),
      additionalInfo: json['additionalInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'severity': severity.value,
      'additionalInfo': additionalInfo,
    };
  }
}

/// Enum for warning severity levels
enum WarningSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const WarningSeverity(this.value);

  static WarningSeverity fromString(String value) {
    return WarningSeverity.values.firstWhere(
          (e) => e.value == value.toLowerCase(),
      orElse: () => WarningSeverity.low,
    );
  }
}

/// Model for when to seek medical help
class WhenToSeekMedicalHelp {
  final String generalGuidance;
  final List<String> urgentSigns;
  final List<String> emergencySigns;
  final String? additionalNotes;

  WhenToSeekMedicalHelp({
    required this.generalGuidance,
    required this.urgentSigns,
    required this.emergencySigns,
    this.additionalNotes,
  });

  factory WhenToSeekMedicalHelp.fromJson(Map<String, dynamic> json) {
    return WhenToSeekMedicalHelp(
      generalGuidance: json['generalGuidance'] as String? ?? '',
      urgentSigns: (json['urgentSigns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      emergencySigns: (json['emergencySigns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      additionalNotes: json['additionalNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generalGuidance': generalGuidance,
      'urgentSigns': urgentSigns,
      'emergencySigns': emergencySigns,
      'additionalNotes': additionalNotes,
    };
  }
}

Future<List<FirstAidCategory>> loadFirstAidCategories(String jsonString) async {
  try {
    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is List) {
      return decoded
          .map((json) => FirstAidCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (decoded is Map<String, dynamic> && decoded.containsKey('categories')) {
      return (decoded['categories'] as List)
          .map((json) => FirstAidCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw FormatException('Invalid JSON format');
  } catch (e) {
    print('Error loading first aid categories: $e');
    rethrow;
  }
}

/// Example function to save first aid categories to JSON string
String saveFirstAidCategories(List<FirstAidCategory> categories) {
  final data = {
    'version': '1.0',
    'lastUpdated': DateTime.now().toIso8601String(),
    'categories': categories.map((c) => c.toJson()).toList(),
  };

  return jsonEncode(data);
}

// Import required for JSON operations
