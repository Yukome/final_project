class Owner {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final DateTime? deletedAt;

  const Owner({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    id: json['id'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse(json['deletedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': phone,
    'email': email,
    'deletedAt': deletedAt?.toIso8601String(),
  };
}