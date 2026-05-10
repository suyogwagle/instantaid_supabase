class FirstAidContent {
  final String id;
  final String category_id;
  final String section_id;
  final String description;

  FirstAidContent({
    required this.id,
    required this.category_id,
    required this.section_id,
    required this.description,
  });

  factory FirstAidContent.fromJson(Map<String, dynamic> json) {
    return FirstAidContent(
      id: json['id'],
      category_id: json['category_id'],
      section_id: json['section_id'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': category_id,
      'section_id': section_id,
      'description': description,
    };
  }
}