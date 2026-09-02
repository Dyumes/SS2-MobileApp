class AppUser {
  final String id;
  final String name;
  final String surname;
  final String address;
  final String email;
  final String role;
  final String? imageUrl;

  AppUser({
    this.id = '',
    required this.name,
    required this.surname,
    required this.address,
    required this.email,
    required this.role,
    this.imageUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String docId) {
    return AppUser(
      id: docId,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'address': address,
      'email': email,
      'role': role,
      'imageUrl': imageUrl ?? '',
    };
  }
}