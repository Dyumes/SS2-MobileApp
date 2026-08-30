import 'package:cloud_firestore/cloud_firestore.dart';


class JobOpportunities {
  final String id;
  final String employer_user;
  final String degree;
  final String jobName;
  final String description;
  final List<String> languages;
  final int salary;
  final int workloadPercentage;
  final String industry;
  final DateTime timestamp;
  final DateTime deadline;

  JobOpportunities({
    this.id = '',
    required this.employer_user,
    required this.degree,
    required this.jobName,
    required this.description,
    required this.languages,
    required this.salary,
    required this.workloadPercentage,
    required this.industry,
    required this.timestamp,
    required this.deadline,
  });

  

  factory JobOpportunities.fromMap(Map<String, dynamic> data, String docId) {
    return JobOpportunities(
      id: docId,
      employer_user: (data['employer_user'] as DocumentReference?)?.id ?? '',
            degree: data['degree'] ?? '',
      jobName: data['jobName'] ?? '',
      description: data['description'] ?? '',
      languages: List<String>.from(data['languages'] ?? []),
      salary: data['salary'] ?? 0,
      workloadPercentage: data['workloadPercentage'] ?? 0,
      industry: data['industry'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'workloadPercentage': workloadPercentage,
      'industry': industry,
      'timestamp': Timestamp.fromDate(timestamp),
      'deadline': Timestamp.fromDate(deadline),
    };
  }

  JobOpportunities copyWith({
    String? id,
    String? employer_user,
    String? degree,
    String? jobName,
    String? description,
    List<String>? languages,
    int? salary,
    int? workloadPercentage,
    String? industry,
    DateTime? timestamp,
    DateTime? deadline,
  }) {
    return JobOpportunities(
      id: id ?? this.id,
      employer_user: employer_user ?? this.employer_user,
      degree: degree ?? this.degree,
      jobName: jobName ?? this.jobName,
      description: description ?? this.description,
      languages: languages ?? this.languages,
      salary: salary ?? this.salary,
      workloadPercentage: workloadPercentage ?? this.workloadPercentage,
      industry: industry ?? this.industry,
      timestamp: timestamp ?? this.timestamp,
      deadline: deadline ?? this.deadline,
    );
  }
}