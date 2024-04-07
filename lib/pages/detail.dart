import 'package:flutter/material.dart';
import 'package:front_manual/main.dart';
import 'package:front_manual/pages/profile_page.dart';
import 'package:front_manual/services/user_service.dart';
import '../models/cartItem.dart';
import '../models/item.dart';
import '../models/cartItem.dart';
import '../models/user.dart';
import 'cart_page.dart';
import 'home.dart';
import '../services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ItemDetailPage extends StatefulWidget {
  final Item item;

  ItemDetailPage({required this.item});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}


class _ItemDetailPageState extends State<ItemDetailPage>with TickerProviderStateMixin {
  int _quantity = 1;
  int _selectedIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
Future<void> addToCart(int product_id, int quantity) async {
  final _userProvider = UserProviderService();
  bool _mounted = false;

  UserMod? user;

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    String? email = currentUser.email;
    user = await UserService.getUser(email!);
    if (_mounted) {
      _userProvider.setUser(user!);
    }
  }
  
  List<dynamic> cartItems = user?.cart ?? [];
  int itemIndex = cartItems.indexWhere((item) => item['product_id'] == product_id);

  if (itemIndex != -1) {
    cartItems[itemIndex]['quantity'] += quantity;
  } else {
    cartItems.add({
      'quantity': quantity,
      'product_id': product_id,
    });
  }
  user?.cart = cartItems;

  if (user != null) {
    UserService.updateUser(user);
  }

  setState(() {
    _animationController.reset();
    _animationController.forward();
  });
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  CartItemModel _createCartItemModel() {
    return CartItemModel(
      item: widget.item,
      quantity: _quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    var userProviderService = Provider.of<UserProviderService>(context, listen: false);
    final Item item = widget.item;
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 400,
              child: Image.network(
                widget.item.image!,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDescriptionText(),
                  const SizedBox(height: 16),
                  _buildNameText(),
                  const SizedBox(height: 8),
                  _buildPriceText(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Cantidad:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _decrementQuantity,
                            icon: const Icon(Icons.remove),
                            iconSize: 24,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 50,
                            child: Center(
                              child: Text(
                                _quantity.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _incrementQuantity,
                            icon: const Icon(Icons.add),
                            iconSize: 24,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          int quantity = _quantity ?? 0;
                          if (_quantity != null) {
                          addToCart(item.id!, _quantity);
                          }
                        },
                        child: const Text('Add to cart', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSellerInfo(),
                      FloatingActionButton(
                        onPressed: () {},
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.chat),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuestions(),
                  const SizedBox(height: 16),
                  _buildReviews(),
                ],
              ),
            ),
          ],
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
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }



  Widget _buildDescriptionText() {
    return Text(
      widget.item.description ?? 'No description available',
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildNameText() {
    return Text(
      widget.item.name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    );
  }

  Widget _buildPriceText() {
    return Text(
      'Price: ${widget.item.price}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSellerInfo() {
    return FutureBuilder<UserMod?>(
      future: UserService.getUserbyId(widget.item.sellerID!),
      builder: (BuildContext context, AsyncSnapshot<UserMod?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          return Text(
            'Vendedor: ${snapshot.data!.name}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildQuestions() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preguntas:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Esta es una pregunta 1',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Esta es una Pregunta 2',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Esta es una Pregunta 3',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Esta es una Pregunta 4',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reseñas:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Reseña 1',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Este es el contenido de la reseña 1.',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),Text(
          'Reseña 2',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Este es el contenido de la reseña 2.',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.item.name),
      backgroundColor: Colors.blueAccent,
      elevation: 5,
    );
  }
}