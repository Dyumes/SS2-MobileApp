class Employer {
  final String id;
  final String companyName;
  final String canton;
  final String city;
  final String companySize;

  Employer({
    this.id = '',
    required this.companyName,
    required this.canton,
    required this.city,
    this.companySize = '',
  });

  factory Employer.fromMap(Map<String, dynamic> map, String docId) {
    return Employer(
      id: docId,
      companyName: map['enterprise_name'] ?? '',
      canton: map['canton'] ?? '',
      city: map['city'] ?? '',
      companySize: map['company_size'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enterprise_name': companyName,
      'canton': canton,
      'city': city,
      'company_size': companySize,
    };
  }
}