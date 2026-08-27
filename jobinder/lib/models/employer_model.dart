class Employer {
  final String id;
  final String enterpriseName;
  final String canton;
  final String city;

  Employer({
    this.id = '',
    required this.enterpriseName,
    required this.canton,
    required this.city,
  });

  factory Employer.fromMap(Map<String, dynamic> map, String docId) {
    return Employer(
      id: docId,
      enterpriseName: map['enterprise_name'] ?? '',
      canton: map['canton'] ?? '',
      city: map['city'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enterprise_name': enterpriseName,
      'canton': canton,
      'city': city,
    };
  }
}