class User {
  final bool success;
  final String token;
  final String role;
  final String name;
  final String id;

  User({this.id, this.name, this.role, this.success, this.token});

  factory User.fromMap(Map<String, dynamic> userData) => User(
        id: userData['id'],
        name: userData['name'],
        token: userData['token'],
        success: userData['success'],
        role: userData['role'],
      );
}
