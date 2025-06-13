import 'package:flutter/material.dart';
import '../../domain/enrollment/models/enrollment.dart';

class StudentProvider extends ChangeNotifier {
  List<EnrollmentWithRelations> students = [];
  int currentIndex = 0;

  EnrollmentWithRelations? get currentStudent =>
      students.isNotEmpty ? students[currentIndex] : null;

  void setStudents(List<EnrollmentWithRelations> newStudents) {
    students = newStudents;
    currentIndex = 0;
    notifyListeners();
  }

  void changeStudent(int index) {
    if (index >= 0 && index < students.length) {
      currentIndex = index;
      notifyListeners();
    }
  }
} 