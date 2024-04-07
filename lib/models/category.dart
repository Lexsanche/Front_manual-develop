class Categoria {
  int? id;
  String name;
  String description;
  String? image;

  Categoria({
    this.id,
    required this.name,
    required this.description,
    this.image,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
    };
  }

  @override
  String toString() {
    return 'Categoria{id: $id, name: $name, description: $description, image: $image}';
  }
}