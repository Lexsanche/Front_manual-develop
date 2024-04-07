// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:front_manual/main.dart';
import 'package:front_manual/pages/profile_page.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import 'detail.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  final String searchQuery;

  const SearchPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ItemService _itemService = ItemService();
  String _searchQuery = '';
  int _selectedIndex = 0;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.searchQuery;
    _fetchAllItems();
  }

  void _fetchAllItems() async {
    try {
      List<Item> allItems = await _itemService.fetchItems();
      setState(() {
        _items = allItems;
      });
    } catch (error) {
      print('Error fetching items: $error');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
      case 2:
        _showFiltersModal();
        break;
    }
  }

  void _showFiltersModal() {
    String localCategory = '';
    String localSellerID = '';
    bool isStockAvailable = true;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) => localCategory = value,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) => localSellerID = value,
                      decoration: const InputDecoration(
                        labelText: 'ID del Vendedor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text('Stock Disponible'),
                      value: isStockAvailable,
                      onChanged: (value) {
                        setState(() {
                          isStockAvailable = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _applyFilters(
                          category: localCategory.isNotEmpty ? localCategory : null,
                          stock: isStockAvailable,
                          sellerID: localSellerID.isNotEmpty ? localSellerID : null,
                        );
                        Navigator.pop(context); // Cerrar el modal
                      },
                      child: const Text('Aplicar Filtros'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _applyFilters({String? category, bool? stock, String? sellerID}) async {
    print('Botón de filtros presionado');
    try {
      List<Item> filteredItems = await _fetchFilteredItems(
        category: category,
        stock: stock,
        sellerID: sellerID,
      );

      setState(() {
        _items = filteredItems;
      });
    } catch (error) {
      print('Error applying filters: $error');
    }
  }

  Future<List<Item>> _fetchFilteredItems({String? category, bool? stock, String? sellerID}) async {
    final Map<String, dynamic> queryParams = {};
    if (category != null) queryParams['category'] = category;
    if (stock != null) queryParams['stock'] = stock.toString();
    if (sellerID != null) queryParams['sellerID'] = sellerID;

    //final Uri uri = Uri.http('34.16.154.218:8000', '/api/items/', queryParams);
    final Uri uri = Uri.http('127.0.0.1:8000', '/api/items/', queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<Item> filteredItems = jsonData.map<Item>((itemJson) => Item.fromJson(itemJson)).toList();
      return filteredItems;
    } else {
      throw Exception('Failed to fetch filtered items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Text(
                'Productos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Buscar producto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFiltersModal,
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3D48BF),
        elevation: 5,
        automaticallyImplyLeading: true,
        toolbarHeight: 120,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildItemsList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildItemsList() {
    final filteredItems = _items.where((item) {
      final itemName = item.name.toLowerCase();
      final searchQuery = _searchQuery.toLowerCase();
      return itemName.contains(searchQuery);

    }).toList();

    return Container(
      color: Colors.white,
      child: filteredItems.isEmpty
          ? const Center(child: Text('No se encontró nada'))
          : ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailPage(item: item),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    item.image != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.image!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(Icons.image_not_supported, size: 100),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${item.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
