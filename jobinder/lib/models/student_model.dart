import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final List<String>? skills;
  final List<History>? history;
  final String? degree;
  final int? minSalary;
  final int? maxDistance;

  Student({
    this.id = '',
    this.skills,
    this.history,
    this.degree,
    this.minSalary,
    this.maxDistance
  });
  factory Student.fromMap(Map<String, dynamic> map, String docId) {
    return Student(
      id: docId,
      skills: List<String>.from(map['skills'] ?? []),
      history: (map['history'] as List<dynamic>? ?? [])
          .map((h) => History.fromMap(Map<String, dynamic>.from(h)))
          .toList(),
      degree: map['degree'],
      minSalary: map['minSalary'],
      maxDistance: map['maxDistance']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skills': skills,
      'history': history?.map((h) => h.toMap()).toList(),
      'degree': degree,
      'minSalary': minSalary,
      'maxDistance': maxDistance
    };
  }
}

class History {
  final String company;
  final String link;
  final DateTime? startDate;
  final DateTime? endDate;

  History({
    required this.company,
    required this.link,
    this.startDate,
    this.endDate,
  });

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      company: map['company'] ?? '',
      link: map['link'] ?? '',
      startDate: (map['start_date'] as Timestamp?)?.toDate(),
      endDate: (map['end_date'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'link': link,
      'start_date': startDate == null ? null : Timestamp.fromDate(startDate!),
      'end_date': endDate == null ? null : Timestamp.fromDate(endDate!),
    };
  }
}