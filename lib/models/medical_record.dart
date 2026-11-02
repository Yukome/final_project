class MedicalRecord {
  final String id;
  final DateTime date;
  final String notes;
  final String petId;
  final String petName;
  final List<String> medicationIds;
  final List<String> serviceIds;
  final DateTime? deletedAt;

  const MedicalRecord({
    required this.id,
    required this.date,
    required this.notes,
    required this.petId,
    this.petName = '—',
    this.medicationIds = const [],
    this.serviceIds = const [],
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    final expand = json['expand'] as Map<String, dynamic>?;
    final pet = expand?['pet'] as Map<String, dynamic>?;

    return MedicalRecord(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String? ?? '',
      petId: json['pet'] as String? ?? '',
      petName: pet?['name'] as String? ?? '—',
      medicationIds: (json['medications'] as List?)?.cast<String>() ?? [],
      serviceIds: (json['services'] as List?)?.cast<String>() ?? [],
      deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse(json['deletedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'notes': notes,
    'pet': petId,
    'medications': medicationIds,
    'services': serviceIds,
    'deletedAt': deletedAt?.toIso8601String(),
  };
}