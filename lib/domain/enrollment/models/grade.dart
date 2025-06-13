import '../enums/academic_level.dart';

class Grade {
  final String id;
  final String name;
  final AcademicLevel level;
  final int order;

  Grade({
    required this.id,
    required this.name,
    required this.level,
    required this.order,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      name: json['name'],
      level: AcademicLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['level'],
        orElse: () => AcademicLevel.primaria,
      ),

      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level.toString().split('.').last,
      'order': order,
    };
  }

  factory Grade.empty() =>
      Grade(id: '', name: '', level: AcademicLevel.primaria, order: 0);
}
