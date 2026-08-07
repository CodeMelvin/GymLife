import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/database_helper.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  final List<Map<String, dynamic>> _cart = [];

  String _userEmail = '';

  List<Map<String, dynamic>> get cart => List.unmodifiable(_cart);
  bool get isEmpty => _cart.isEmpty;

  int get totalPrice =>
      _cart.fold(0, (sum, item) => sum + (item['price'] as int));

  void setActiveUser(String email) {
    _userEmail = email;
    loadCart();
  }

  Future<void> loadCart() async {
    final db = await _helper.database;
    final rows = await db.query(
      'cart',
      where: 'user_email = ?',
      whereArgs: [_userEmail],
      orderBy: 'id ASC',
    );
    _cart
      ..clear()
      ..addAll(rows.map(_rowToItem));
    notifyListeners();
  }

  Map<String, dynamic> _rowToItem(Map<String, Object?> row) {
    return {
      'rowId': row['id'],
      'id': row['membership_id'],
      'name': row['name'],
      'description': row['description'],
      'price': row['price'],
      'image': row['image'],
      'benefits': List<String>.from(
        jsonDecode(row['benefits'] as String) as List,
      ),
      'paymentMethod': row['payment_method'],
      'status': row['status'],
    };
  }

  Future<void> addToCart({
    required int id,
    required String name,
    required String description,
    required int price,
    required String image,
    required List<String> benefits,
    required String paymentMethod,
  }) async {
    final db = await _helper.database;
    await db.insert('cart', {
      'user_email': _userEmail,
      'membership_id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'benefits': jsonEncode(benefits),
      'payment_method': paymentMethod,
      'status': 'In Cart',
    });
    await loadCart();
  }

  Future<void> updateStatus(int rowId, String newStatus) async {
    final db = await _helper.database;
    await db.update(
      'cart',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [rowId],
    );
    final index = _cart.indexWhere((item) => item['rowId'] == rowId);
    if (index != -1) {
      _cart[index]['status'] = newStatus;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int rowId) async {
    final db = await _helper.database;
    await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [rowId],
    );
    _cart.removeWhere((item) => item['rowId'] == rowId);
    notifyListeners();
  }
}
