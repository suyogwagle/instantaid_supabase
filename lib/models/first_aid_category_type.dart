class FirstAidCategoryType {
  final String id;
  final String type;

  FirstAidCategoryType({
    required this.id,
    required this.type,
  });

  factory FirstAidCategoryType.fromJson(Map<String, dynamic> json) {
    return FirstAidCategoryType(
      id: json['id'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}