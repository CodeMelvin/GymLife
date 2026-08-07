import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/cart_provider.dart';
import '../../providers/profile_provider.dart';

class PaymentPendingPage extends StatelessWidget {
  final String membershipId;
  final String membershipName;
  final int rowId;

  const PaymentPendingPage({
    super.key,
    required this.membershipId,
    required this.membershipName,
    required this.rowId,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final profile = Provider.of<ProfileProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Invoice',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 36, 42, 99),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            cart.updateStatus(rowId, 'Waiting for Payment');
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFF060F3F),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Show this QR Code to cashier to complete payment.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: 'Membership ID: $membershipId - $membershipName',
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                'I already pay',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                cart.updateStatus(rowId, 'Paid');
                await profile.setMembership(
                  membershipName,
                  DateTime.now().add(const Duration(days: 30)),
                );
                await cart.removeFromCart(rowId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membership activated successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
