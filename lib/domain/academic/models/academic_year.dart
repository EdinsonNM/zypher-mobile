class AcademicYear {
  final String? id;
  final int? year;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? name;
  final bool? isActive;

  AcademicYear({
    this.id,
    this.year,
    this.startDate,
    this.endDate,
    this.name,
    this.isActive,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id'],
      year: json['year'],
      startDate:
          json['start_date'] != null
              ? DateTime.parse(json['start_date'])
              : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      name: json['name'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'name': name,
      'is_active': isActive,
    };
  }
}
