import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/membership.dart';
import '../../providers/cart_provider.dart';
import '../../utils/format.dart';
import '../home/home_page.dart';

class MembershipDetailPage extends StatelessWidget {
  final Membership membership;

  const MembershipDetailPage({super.key, required this.membership});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final primaryColor = membership.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('${membership.name} Privilege'),
        backgroundColor: primaryColor.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(primaryColor),
              const SizedBox(height: 16),
              Text(membership.description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              const Text(
                'Benefits',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildBenefitsGrid(primaryColor)),
              const SizedBox(height: 8),
              const Text(
                'Payment Method:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              _buildPaymentMethod(primaryColor),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAddToCartButton(context, cart, primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(membership.image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.25),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${membership.name} Member',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatRupiah(membership.price)} / Month',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsGrid(Color color) {
    const iconMap = {
      'Free Parking': Icons.directions_car,
      'Personal Locker': Icons.lock,
      'VIP Gym Room': Icons.star,
      '4 Times Trainer': Icons.fitness_center,
      '2 Times Trainer': Icons.fitness_center,
    };

    return GridView.builder(
      itemCount: membership.benefits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        final benefit = membership.benefits[index];
        final icon = iconMap[benefit] ?? Icons.check_circle_outline;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(12),
            color: color.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.black87, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    benefit,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethod(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cash',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Icon(Icons.money, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(
    BuildContext context,
    CartProvider cart,
    Color color,
  ) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.shopping_cart_checkout_rounded),
      label: const Text(
        'Add to Cart',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        await cart.addToCart(
          id: membership.id,
          name: membership.name,
          description: membership.description,
          price: membership.price,
          image: membership.image,
          benefits: membership.benefits,
          paymentMethod: 'Cash',
        );
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuScreen(initialIndex: 1)),
        );
      },
    );
  }
}
