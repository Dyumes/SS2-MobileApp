class Employer {
  final String user_id;
  final String canton;
  final String city;
  final String entrepiseName;

  Employer({
    required this.user_id,
    required this.canton,
    required this.city,
    required this.entrepiseName,
  });

  factory Employer.fromMap(Map<String, dynamic> data, String docId) {
    return Employer(
      user_id: data['user_id'] ?? '',
      canton: data['canton'] ?? '',
      city: data['city'] ?? '',
      entrepiseName: data['entrepiseName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'canton': canton,
      'city': city,
      'entrepiseName': entrepiseName,
    };
  }

  Employer copyWith({
    String? user_id,
    String? canton,
    String? city,
    String? entrepiseName,
  }) {
    return Employer(
      user_id: user_id ?? this.user_id,
      canton: canton ?? this.canton,
      city: city ?? this.city,
      entrepiseName: entrepiseName ?? this.entrepiseName,
    );
  }
}