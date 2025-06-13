enum AcademicLevel {
  inicial('Inicial'),
  primaria('Primaria'),
  secundaria('Secundaria');

  final String value;

  const AcademicLevel(this.value);

  factory AcademicLevel.fromString(String value) {
    return AcademicLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AcademicLevel.primaria,
    );
  }

  @override
  String toString() => value;
}
