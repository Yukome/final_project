class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String ownerId;
  final DateTime? deletedAt;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.ownerId,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    species: json['species'] as String? ?? '',
    breed: json['breed'] as String? ?? '',
    ownerId: json['owner'] as String? ?? '',
    deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse(json['deletedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'species': species,
    'breed': breed,
    'owner': ownerId,
    'deletedAt': deletedAt?.toIso8601String(),
  };
}