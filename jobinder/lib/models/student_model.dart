class Student {
  final String id;
  final List<String>? skills;
  final List<History>? history;

  Student({
    this.id = '',
    this.skills,
    this.history,
  });

  factory Student.fromMap(Map<String, dynamic> map, String docId) {
    return Student(
      id: docId,
      skills: List<String>.from(map['skills'] ?? []),
      history: List<History>.from(map['history'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skills': skills,
      'history': history?.map((h) => h.toMap()).toList(),
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
      startDate: map['start_date'],
      endDate: map['end_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'position': link,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}