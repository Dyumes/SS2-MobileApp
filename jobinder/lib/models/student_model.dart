class Student {
  final String id;
  final List<String> skills;
  final String history;

  Student({
    this.id = '',
    required this.skills,
    required this.history,
  });

  factory Student.fromMap(Map<String, dynamic> map, String docId) {
    return Student(
      id: docId,
      skills: List<String>.from(map['skills'] ?? []),
      history: map['history'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skills': skills,
      'history': history,
    };
  }
}