class UserMod {
  int? id;
  String name;
  String email;
  String password;
  String shippingAddress;
  List<dynamic>? cart;
  List<dynamic>? reviews;
  List<dynamic>? questions;

  UserMod({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.shippingAddress,
    this.cart,
    this.reviews,
    this.questions,
  });

  factory UserMod.fromJson(Map<String, dynamic> json) {
    return UserMod(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      shippingAddress: json['shippingAddress'],
      cart: json['cart'] != null ? List<dynamic>.from(json['cart']) : null,
      reviews: json['reviews'] != null ? List<dynamic>.from(json['reviews']) : null,
      questions: json['questions'] != null ? List<dynamic>.from(json['questions']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'shippingAddress': shippingAddress,
      'cart': cart,
      'reviews': reviews,
      'questions': questions,
    };
  }
}
