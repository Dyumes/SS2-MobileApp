import 'package:cloud_firestore/cloud_firestore.dart';


class Employer {
  final String user_id;
  final String canton;
  final String city;
  final String entrepriseName;

  Employer({
    required this.user_id,
    required this.canton,
    required this.city,
    required this.entrepriseName,
  });

  factory Employer.fromMap(Map<String, dynamic> data, String docId) {
    return Employer(
      user_id: (data['user_id'] as DocumentReference?)?.id ?? '',
      canton: data['canton'] ?? '',
      city: data['city'] ?? '',
      entrepriseName: data['entreprise_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'canton': canton,
      'city': city,
      'entrepiseName': entrepriseName,
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
      entrepriseName: entrepiseName ?? this.entrepriseName,
    );
  }
}