class Admin {
  final String username;
  final String password;

  Admin({required this.username, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      username: map['username'],
      password: map['password'],
    );
  }
}
