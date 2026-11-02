enum Role {
  owner(1),
  doctor(2),
  admin(3);

  final int level;
  const Role(this.level);
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final Role role;
  final String? ownerId;
  final String? doctorId;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.ownerId,
    this.doctorId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: switch (json['role']) {
        'admin' => Role.admin,
        'doctor' => Role.doctor,
        _ => Role.owner,
      },
      ownerId: json['ownerId'] as String?,
      doctorId: json['doctorId'] as String?,
    );
  }
}