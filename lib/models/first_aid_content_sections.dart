class FirstAidContentSection {
  final String id;
  final String section;

  FirstAidContentSection({
    required this.id,
    required this.section,
  });

  factory FirstAidContentSection.fromJson(Map<String, dynamic> json) {
    return FirstAidContentSection(
      id: json['id'],
      section: json['section'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
    };
  }
}