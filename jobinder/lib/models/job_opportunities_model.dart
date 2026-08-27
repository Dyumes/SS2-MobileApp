import 'package:cloud_firestore/cloud_firestore.dart';


class JobOpportunities {
  final String employer_user;
  final String degree;
  final String jobName;
  final String description;
  final List<String> languages;
  final int salary;

  JobOpportunities({
    required this.employer_user,
    required this.degree,
    required this.jobName,
    required this.description,
    required this.languages,
    required this.salary,
  });

  

  factory JobOpportunities.fromMap(Map<String, dynamic> data, String docId) {
    return JobOpportunities(
      employer_user: (data['employer_user'] as DocumentReference?)?.id ?? '',
            degree: data['degree'] ?? '',
      jobName: data['jobName'] ?? '',
      description: data['description'] ?? '',
      languages: List<String>.from(data['languages'] ?? []),
      salary: data['salary'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employer_user': employer_user,
      'degree': degree,
      'jobName': jobName,
      'description': description,
      'languages': languages,
      'salary': salary,
    };
  }

  JobOpportunities copyWith({
    String? employer_user,
    String? degree,
    String? jobName,
    String? description,
    List<String>? languages,
    int? salary,
  }) {
    return JobOpportunities(
      employer_user: employer_user ?? this.employer_user,
      degree: degree ?? this.degree,
      jobName: jobName ?? this.jobName,
      description: description ?? this.description,
      languages: languages ?? this.languages,
      salary: salary ?? this.salary,
    );
  }
}