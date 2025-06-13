class ObservationCategory {
  String? id;
  String name;
  String? description;
  String? color;
  String? icon;
  bool isActive = true;
  DateTime? createdAt;
  DateTime? updatedAt;

  ObservationCategory({
    this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ObservationCategory.fromJson(Map<String, dynamic> json) {
    return ObservationCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
      icon: json['icon'],
      isActive: json['is_active'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
