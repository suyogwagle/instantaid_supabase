class FirstAidSubCategory {
  final String id;
  final String sub_category;
  final String description;

  FirstAidSubCategory({
    required this.id,
    required this.sub_category,
    required this.description,
  });

  factory FirstAidSubCategory.fromJson(Map<String, dynamic> json) {
    return FirstAidSubCategory(
      id: json['id'],
      sub_category: json['sub_category'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sub_category': sub_category,
      'description': description,
    };
  }
}