import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/item.dart';

class ItemService {
  //final String _baseUrl = 'http://34.16.154.218:8000';
  static String _baseUrl = 'http://127.0.0.1:8000';


  Future<List<Item>> fetchItems() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/items/'));

    if (response.statusCode == 200) {
      List<dynamic> itemsJson = json.decode(response.body);
      return itemsJson.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }
  static Future<Item?> getProduct(int itemId)async {
    final String _baseUrl = 'http://127.0.0.1:8000';
    //final String _baseUrl = 'http://34.16.154.218:8000';
    final response = await http.get(Uri.parse('$_baseUrl/api/items/$itemId'));
        if (response.statusCode == 200) {
    final Map<String, dynamic> itemJson = json.decode(response.body);
    return Item.fromJson(itemJson);
  } else if (response.statusCode == 404) {
    return null;
  } else {
    throw Exception('Failed to get item with ID $itemId');
  }
  }
  Future<List<Item>> searchItems(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/items/?search=$query'));

    if (response.statusCode == 200) {
      List<dynamic> itemsJson = json.decode(response.body);
      return itemsJson.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search items');
    }
  }
  Future<Item> createItem(Item item) async {
    var url = Uri.parse('$_baseUrl/api/items/');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode(item.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Item.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to create item');
    }
  }

  Future<List<Item>> getProductsByID(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/items/?sellerID=$userId'));

    if (response.statusCode == 200) {
      List<dynamic> itemsJson = json.decode(response.body);
      return itemsJson.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items for user ID: $userId');
    }
  }

  Future<List<Item>> getItemsByCategory(String categoryName) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/items/?category=$categoryName'));

    if (response.statusCode == 200) {
      List<dynamic> itemsJson = json.decode(response.body);
      return itemsJson.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items for Category: $categoryName');
    }
  }

  Future<void> deleteItemById(int itemId) async {
    var url = Uri.parse('$_baseUrl/api/items/$itemId/');
    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Item with ID $itemId not found');
    } else {
      throw Exception('Failed to delete item with ID $itemId');
    }
  }

  Future<Item> editItemById(int itemId, Item newItemData) async {
    var url = Uri.parse('$_baseUrl/api/items/$itemId/');
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode(newItemData.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Item.fromJson(jsonResponse);
    } else if (response.statusCode == 404) {
      throw Exception('Item with ID $itemId not found');
    } else {
      throw Exception('Failed to update item with ID $itemId');
    }
  }


}