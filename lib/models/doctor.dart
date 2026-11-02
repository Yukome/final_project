class Doctor {
  final String id;
  final String fullName;
  final String specialization;
  final List<String> serviceIds;
  final DateTime? deletedAt;

  const Doctor({
    required this.id,
    required this.fullName,
    required this.specialization,
    this.serviceIds = const [],
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    specialization: json['specialization'] as String? ?? '',
    serviceIds: (json['services'] as List?)?.cast<String>() ?? [],
    deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse(json['deletedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'specialization': specialization,
    'services': serviceIds,
    'deletedAt': deletedAt?.toIso8601String(),
  };
}