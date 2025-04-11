class UserModel {
  final String id;
  final String uid;
  final String email;
  final String username;
  final List<int> roles;
  final String status;
  final String name; // <- New field

  UserModel({
    required this.id,
    required this.uid,
    required this.email,
    required this.username,
    required this.roles,
    required this.status,
    required this.name,
  });

  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? username,
    List<int>? roles,
    String? status,
    String? name,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'email': email,
        'username': username,
        'roles': roles,
        'status': status,
        'name': name,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        uid: map['uid'] ?? '',
        email: map['email'],
        username: map['username'],
        roles: List<int>.from(map['roles'] ?? []),
        status: map['status'] ?? 'inactive',
        name: map['name'] ?? '',
      );
}
