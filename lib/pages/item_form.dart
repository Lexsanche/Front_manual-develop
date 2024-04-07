import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front_manual/pages/profile_page.dart';

import '../models/item.dart';
import '../models/user.dart';
import '../services/item_service.dart';
import '../services/user_service.dart';

class ItemForm extends StatefulWidget {
  final Item? itemToEdit;

  ItemForm({Key? key, this.itemToEdit}) : super(key: key);

  @override
  _ItemFormState createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserMod? _user;

  late String _name = '';
  late double _price = 0.0;
  late int _category = 0;
  late String? _description= '';
  late String? _imageUrl= '';
  late bool _hasStock = false;

  Future<void> _fetchData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String? email = currentUser.email;
        _user = await UserService.getUser(email!);
      }
    } catch (e) {
      print('Exception caught: $e');
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _initializeFormFields();
    }
  }

  void _initializeFormFields() {
    final item = widget.itemToEdit!;
    _name = item.name;
    _price = item.price;
    _category = item.category;
    _description = item.description;
    _imageUrl = item.image;
    _hasStock = item.stock;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D48BF),
        title: Text(widget.itemToEdit == null ? 'Agregar producto' : 'Editar producto'),
      ),
      body: _buildForm(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            await _fetchData();

            if (widget.itemToEdit == null) {
              final newItem = Item(
                sellerID: _user?.id,
                name: _name,
                category: _category,
                description: _description ?? '',
                price: _price,
                stock: _hasStock,
                image: _imageUrl ?? '',
                created_at: DateTime.now(),
              );
              try {
                final createdItem = await ItemService().createItem(newItem);
                print('Created product: ${createdItem.name}');
              } catch (e) {
                print('Error creating product: $e');
              }
            } else {
              final editedItem = widget.itemToEdit!.copyWith(
                name: _name,
                category: _category,
                description: _description ?? '',
                price: _price,
                stock: _hasStock,
                image: _imageUrl ?? '',
              );
              try {
                await ItemService().editItemById(widget.itemToEdit!.id!, editedItem);
                print('Edited product: ${editedItem.name}');
              } catch (e) {
                print('Error editing product: $e');
              }
            }
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
                  (route) => false,
            );
          }
        },

        child: Icon(Icons.save),

      ),
    );
  }


  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese un nombre para el producto';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _price.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Precio'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese un precio para el producto';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un precio válido';
                }
                return null;
              },
              onSaved: (value) => _price = double.parse(value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _category.toString(),
              decoration: InputDecoration(labelText: 'Categoría'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese una categoría para el producto';
                }
                if (int.tryParse(value) == null) {
                  return 'Ingrese una categoría válida (número)';
                }
                return null;
              },
              onSaved: (value) => _category = int.parse(value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _description ?? '',
              decoration: InputDecoration(labelText: 'Descripción'),
              onSaved: (value) => _description = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _imageUrl ?? '',
              decoration: InputDecoration(labelText: 'URL de la imagen'),
              onSaved: (value) => _imageUrl = value,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Disponibilidad:'),
                Switch(
                  value: _hasStock,
                  onChanged: (value) {
                    setState(() {
                      _hasStock = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
