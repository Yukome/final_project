class Diagnosis {
  final String id;
  final String name;
  final String description;
  final DateTime? deletedAt;

  const Diagnosis({
    required this.id,
    required this.name,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  factory Diagnosis.fromJson(Map<String, dynamic> json) => Diagnosis(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse(json['deletedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'deletedAt': deletedAt?.toIso8601String(),
  };
}