import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front_manual/pages/login_page.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../services/item_service.dart';
import '../services/user_provider.dart';
import '../services/user_service.dart';
import 'detail.dart';
import 'home.dart';
import 'item_form.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserMod? _user;
  List<Item> _products = [];
  final _itemService = ItemService();
  final _userProvider = UserProviderService();
  int _selectedIndex = 0;
  bool _mounted = false;


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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }



  @override
  void initState() {
    super.initState();
    _mounted = true;
    _fetchData();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _checkUserLoggedIn() {
    var userProvider = Provider.of<UserProviderService>(context, listen: false);
    if (userProvider.user == null && _mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
  }

  void _fetchData() {
    _fetchUser().then((_) {
      if (_mounted) {
        setState(() {});
      }
    });
    _fetchProducts();
  }

  Future<void> _fetchUser() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String? email = currentUser.email;
        UserMod? user = await UserService.getUser(email!);
        if (_mounted) {
          _userProvider.setUser(user!);
        }
      }
      else{
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  Future<void> _fetchProducts() async {
    if (_userProvider.user == null) {
      return;
    }
    try {
      int? userID = _userProvider.user?.id;
      List<Item> products = await _itemService.getProductsByID(userID!);
      setState(() {
        _products = products;
      });
    } catch (e) {
      print('Exception caught: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D48BF),
        actions: [],
      ),
      body: _userProvider.user == null
          ? Center(
        child: _buildProfileInfo(),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileInfo(),
            Divider(),
            SizedBox(height: 16),
            const Text(
              'Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemForm(),
                  ),
                );
              },
              child: const Text('Agregar producto'),
            ),
            _buildProductsList(),
          ],
        ),
      ),
      floatingActionButton: _userProvider.user != null
          ? FloatingActionButton.extended(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ),
          );
        },
        label: const Text('Logout'),
        icon: const Icon(Icons.logout),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }


  Widget _buildProfileInfo() {
    if (_userProvider.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://source.unsplash.com/random/800x600/?portrait',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userProvider.user!.name,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _userProvider.user!.email,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                _userProvider.user!.shippingAddress,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildProductsList() {
    int? userID = _userProvider.user?.id;
    return Expanded(
      child: FutureBuilder<List<Item>>(
        future: _userProvider.user == null ? _itemService.fetchItems() : _itemService.getProductsByID(userID!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
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
                          SizedBox(width: 16),
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
                                SizedBox(height: 8),
                                Text(
                                  item.description ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
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
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemForm(itemToEdit: item),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content: Text('Are you sure you want to delete this item?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              await _itemService.deleteItemById(item.id!);
                                              setState(() {});
                                              Navigator.of(context).pop();
                                            } catch (e) {
                                              print('Error deleting item: $e');
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text('Failed to delete item'),
                                              ));
                                            }
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}