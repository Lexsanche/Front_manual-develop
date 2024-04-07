import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../services/user_provider.dart';
import '../services/item_service.dart';
import '../pages/login_page.dart';
import '../models/cartItem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:front_manual/services/user_service.dart';
import '../models/user.dart';
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItemModel> cartItems = [];
  bool _isLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var userProvider = Provider.of<UserProviderService>(context, listen: false);
    loadCartItems();
      }
  void _increaseQuantity(CartItemModel item) {
    setState(() {
      item.quantity++;
    });
    _updateUserCart(); 
  }
  void _decreaseQuantity(CartItemModel item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      }
    });
    _updateUserCart(); 
  }
Future<void> loadCartItems() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  UserMod? user;
  if (currentUser != null) {
    String? email = currentUser.email;
    user = await UserService.getUser(email!);
  }
  
  List<CartItemModel> tempCartItems = [];

  if (user?.cart != null) {
    for (var cartItem in user!.cart!) {
      var productDetails = await ItemService.getProduct(cartItem["product_id"]);
      if (productDetails != null) {
        tempCartItems.add(CartItemModel(item: productDetails, quantity: cartItem["quantity"]));
      }
    }
  }
  setState(() {
    cartItems = tempCartItems;
  });
}


  double get totalPrice {
    double total = 0.0;
    for (var item in cartItems) {
      double itemTotalPrice = item.quantity * item.item.price;
      total += itemTotalPrice;
    }
    return total;
  }
  void _deleteItem(CartItemModel item) {
    setState(() {
      cartItems.remove(item); 
    });
    _updateUserCart();
  }

  void _updateUserCart() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return; 

  UserMod? user = await UserService.getUser(currentUser.email!);
  if (user == null) return; 
  List<Map<String, dynamic>> updatedCart = cartItems.map((cartItem) => {
    "product_id": cartItem.item.id,
    "quantity": cartItem.quantity,
  }).toList();
  user.cart = updatedCart;
  await UserService.updateUser(user);
}



  Widget _buildCartItem(CartItemModel item) {
    return ListTile(
      leading: Image.network(item.item.image ?? '', width: 50, height: 50),
      title: Text(item.item.name),
      subtitle: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => _decreaseQuantity(item),
          ),
          Text('${item.quantity}'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _increaseQuantity(item),
          ),
        ],
      ),
      trailing: Wrap(
        spacing: 12,
        children: <Widget>[
          Text('\$${(item.item.price * item.quantity).toStringAsFixed(2)}'),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => _deleteItem(item),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('Carrito de compras', style: TextStyle(color: Color.fromARGB(255, 240, 240, 240),fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor:const Color.fromARGB(255, 61, 72, 191),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
              return _buildCartItem(cartItems[index]);
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 20)),
                Text('\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
        const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Checkout', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
