class Medication {
  final String id;
  final String name;
  final String dosage;
  final DateTime? deletedAt;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    dosage: json['dosage'] as String? ?? '',
    deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse(json['deletedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'dosage': dosage,
    'deletedAt': deletedAt?.toIso8601String(),
  };
}