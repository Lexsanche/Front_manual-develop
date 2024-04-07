import '../models/item.dart';

class CartItemModel {
  Item item;
  int quantity;

  CartItemModel({required this.item, required this.quantity});

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'quantity': quantity,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      item: Item.fromJson(json['item']),
      quantity: json['quantity'],
    );
  }
}