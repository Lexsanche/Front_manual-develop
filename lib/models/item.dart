class Item {
  final int? id;
  final int? sellerID;
  final String name;
  final int category;
  final String? description;
  final double price;
  final bool stock;
  final String? image;
  final String? reviews;
  final DateTime created_at;

  Item({
    this.id,
    this.sellerID,
    required this.name,
    required this.category,
    this.description,
    required this.price,
    required this.stock,
    this.image,
    this.reviews,
    required this.created_at,
  });

  Item copyWith({
    int? id,
    int? sellerID,
    String? name,
    int? category,
    String? description,
    double? price,
    bool? stock,
    String? image,
    String? reviews,
    DateTime? created_at,
  }) {
    return Item(
      id: id ?? this.id,
      sellerID: sellerID ?? this.sellerID,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      reviews: reviews ?? this.reviews,
      created_at: created_at ?? this.created_at,
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      sellerID: json['sellerID'],
      name: json['name'] ?? 'Unnamed Item',
      category: json['category'] ?? 'Unknown Category',
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      stock: json['stock'] ?? false,
      image: json['image'],
      reviews: json['reviews'],
      created_at: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sellerID': sellerID,
    'name': name,
    'category': category,
    'description': description,
    'price': price,
    'stock': stock,
    'image': image,
    'reviews': reviews,
    'created_at': created_at.toIso8601String(),
  };
}
