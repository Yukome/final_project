class Appointment {
  final String id;
  final DateTime date;
  final String status;
  final String petId;
  final String doctorId;
  final String petName;
  final String doctorName;
  final DateTime? deletedAt;

  const Appointment({
    required this.id,
    required this.date,
    required this.status,
    required this.petId,
    required this.doctorId,
    this.petName = '',
    this.doctorName = '',
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final expand = json['expand'] as Map<String, dynamic>?;
    final pet = expand?['pet'] as Map<String, dynamic>?;
    final doctor = expand?['doctor'] as Map<String, dynamic>?;

    return Appointment(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'waiting',
      petId: json['pet'] as String? ?? '',
      doctorId: json['doctor'] as String? ?? '',
      petName: pet?['name'] as String? ?? '—',
      doctorName: doctor?['fullName'] as String? ?? '—',
      deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse(json['deletedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'status': status,
    'pet': petId,
    'doctor': doctorId,
    'deletedAt': deletedAt?.toIso8601String(),
  };
}