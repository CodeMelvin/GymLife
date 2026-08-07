import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../utils/format.dart';
import '../invoice/payment_pending_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 15, 63),
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 36, 42, 99),
      ),
      body: cart.isEmpty
          ? const Center(
              child: Text('Empty cart!', style: TextStyle(color: Colors.white)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.cart.length,
              itemBuilder: (context, index) {
                final item = cart.cart[index];
                return _CartItemCard(item: item);
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CartFooter(cart: cart),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final isWaiting = item['status'] == 'Waiting for Payment';

    return GestureDetector(
      onTap: () {
        if (isWaiting) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentPendingPage(
                membershipId: item['id'].toString(),
                membershipName: item['name'],
                rowId: item['rowId'] as int,
              ),
            ),
          );
        }
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            item['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                item['description'],
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Text(
                'Price: ${formatRupiah(item['price'] as int)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Status: ${item['status']}',
                style: TextStyle(
                  color: isWaiting ? Colors.orange : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              cart.removeFromCart(item['rowId'] as int);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  final CartProvider cart;

  const _CartFooter({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${formatRupiah(cart.totalPrice)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              final item = cart.cart.first;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentPendingPage(
                    membershipId: item['id'].toString(),
                    membershipName: item['name'],
                    rowId: item['rowId'] as int,
                  ),
                ),
              );
            },
            child: const Text('Checkout', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
