class Student {
  final String? thumbnail;
  final String? id;
  final String firstName;
  final String lastName;
  final DateTime? birthdate;
  final String documentType;
  final String documentNumber;
  final String sex;
  final String phone;

  Student({
    this.thumbnail,
    this.id,
    required this.firstName,
    required this.lastName,
    this.birthdate,
    required this.documentType,
    required this.documentNumber,
    required this.sex,
    required this.phone,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      thumbnail: json['thumbnail'],
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      birthdate:
          json['birthdate'] != null
              ? DateTime.tryParse(json['birthdate'])
              : null,
      documentType: json['document_type'] ?? '',
      documentNumber: json['document_number'] ?? '',
      sex: json['sex'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'birthdate': birthdate?.toIso8601String(),
      'document_type': documentType,
      'document_number': documentNumber,
      'sex': sex,
      'phone': phone,
    };
  }

  factory Student.empty() => Student(
    thumbnail: null,
    id: null,
    firstName: '',
    lastName: '',
    birthdate: null,
    documentType: '',
    documentNumber: '',
    sex: '',
    phone: '',
  );
}
