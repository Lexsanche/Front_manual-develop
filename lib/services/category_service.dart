import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/user.dart';

class CategoryService {
  //static String _baseUrl = 'http://34.16.154.218:8000';
  static String _baseUrl = 'http://127.0.0.1:8000';

  Future<List<Categoria>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/categorias/'));

    if (response.statusCode == 200) {
      final categoriesJson = json.decode(response.body);
      return categoriesJson.map<Categoria>((json) => Categoria.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Categoria> getCategoryById(int categoryId) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/categorias/$categoryId/'));

    if (response.statusCode == 200) {
      final categoryJson = json.decode(response.body);
      return Categoria.fromJson(categoryJson);
    } else {
      throw Exception('Failed to load category');
    }
  }

}