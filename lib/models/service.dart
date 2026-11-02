class Service {
  final String id;
  final String name;
  final double price;
  final DateTime? deletedAt;

  const Service({
    required this.id,
    required this.name,
    required this.price,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse(json['deletedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'deletedAt': deletedAt?.toIso8601String(),
  };
}