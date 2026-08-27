class AppUser {
  final String id;
  final String name;
  final String surname;
  final String address;
  final String email;

  AppUser({
    this.id = '',
    required this.name,
    required this.surname,
    required this.address,
    required this.email,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String docId) {
    return AppUser(
      id: docId,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'address': address,
      'email': email,
    };
  }
}