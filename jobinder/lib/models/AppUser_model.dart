class AppUser {
  final String name;
  final String surname;
  final String email;
  final String adress;

  AppUser({
    required this.name,
    required this.surname,
    required this.email,
    required this.adress,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      email: data['email'] ?? '',
      adress: data['adress'] ?? '',
    );
  }
}