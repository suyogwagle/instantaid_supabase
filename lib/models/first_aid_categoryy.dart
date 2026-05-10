class FirstAidCategoryy{
  final int id;
  final String category;
  final String sub_category;
  final String type;
  final String age_group;

  FirstAidCategoryy({
    required this.id,
    required this.category,
    required this.sub_category,
    required this.type,
    required this.age_group,
});
  
  factory FirstAidCategoryy.fromJson(Map<String, dynamic> json){
    return FirstAidCategoryy(
        id: json['id'],
        category: json['category'],
        sub_category: json['sub_category'],
        type: json['type'],
        age_group: json['age_group'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'category': category,
      'sub_category': sub_category,
      'type': type,
      'age_group': age_group,
    };
  }
}

