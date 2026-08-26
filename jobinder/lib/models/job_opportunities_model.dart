class JobOpportunities {
  final String id;
  final String adress;
  final String canton;
  final String city;
  final String degree;
  final String jobName;
  final String description;
  final List<String> languages;
  final String name;
  final int salary;
  final DateTime timestamp;

  JobOpportunities({
    required this.id,
    required this.adress,
    required this.canton,
    required this.city,
    required this.degree,
    required this.jobName,
    required this.description,
    required this.languages,
    required this.name,
    required this.salary,
    required this.timestamp,
  });

  

  factory JobOpportunities.fromMap(Map<String, dynamic> data, String docId) {
    return JobOpportunities(
      id: docId,
      adress: data['adress'] ?? '',
      canton: data['canton'] ?? '',
      city: data['city'] ?? '',
      degree: data['degree'] ?? '',
      jobName: data['jobName'] ?? '',
      description: data['description'] ?? '',
      languages: List<String>.from(data['languages'] ?? []),
      name: data['name'] ?? '',
      salary: data['salary'] ?? 0,
      timestamp: data['timestamp'] ?? DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adress': adress,
      'canton': canton,
      'city': city,
      'degree': degree,
      'jobName': jobName,
      'description': description,
      'languages': languages,
      'name': name,
      'salary': salary,
      'timestamp': timestamp,
    };
  }

  JobOpportunities copyWith({
    String? id,
    String? adress,
    String? canton,
    String? city,
    String? degree,
    String? jobName,
    String? description,
    List<String>? languages,
    String? name,
    int? salary,
    DateTime? timestamp,
  }) {
    return JobOpportunities(
      id: id ?? this.id,
      adress: adress ?? this.adress,
      canton: canton ?? this.canton,
      city: city ?? this.city,
      degree: degree ?? this.degree,
      jobName: jobName ?? this.jobName,
      description: description ?? this.description,
      languages: languages ?? this.languages,
      name: name ?? this.name,
      salary: salary ?? this.salary,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}