class Job {
  final String details;
  final String name;

  Job({
    required this.details,
    required this.name,
  });

  factory Job.fromMap(Map<String, dynamic> map, String docId) {
    return Job(
      details: map['details'] ?? '',
      name: map['name'] ?? '',
    );
  }
}