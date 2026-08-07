import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../../models/membership.dart';
import '../../providers/profile_provider.dart';
import '../../utils/format.dart';
import '../cart/cart_page.dart';
import '../membership/membership_detail_page.dart';
import '../profile/profile_page.dart';

class MenuScreen extends StatefulWidget {
  final int initialIndex;
  const MenuScreen({super.key, this.initialIndex = 0});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildMenuPage(context),
      const CartPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 15, 63),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 36, 42, 99),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildMenuPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Select Membership',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: kMemberships.length,
            itemBuilder: (context, i) {
              final m = kMemberships[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MembershipDetailPage(membership: m),
                    ),
                  );
                },
                child: _membershipTile(m),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color.fromARGB(255, 36, 42, 99),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Consumer<ProfileProvider>(
            builder: (context, profile, _) => GestureDetector(
              onTap: () {
                if (profile.imageFile != null) {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: ClipOval(
                          child: PhotoView(
                            imageProvider: FileImage(profile.imageFile!),
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            minScale: PhotoViewComputedScale.covered,
                            maxScale: PhotoViewComputedScale.covered * 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[700],
                backgroundImage: profile.imageFile != null
                    ? FileImage(profile.imageFile!)
                    : null,
                child: profile.imageFile == null
                    ? const Icon(Icons.person, color: Colors.white70)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Consumer<ProfileProvider>(
            builder: (context, profile, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isNotEmpty ? profile.name : 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (profile.gender.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        profile.gender.toLowerCase() == 'male'
                            ? Icons.male
                            : Icons.female,
                        color: profile.gender.toLowerCase() == 'male'
                            ? Colors.blue
                            : Colors.pink,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.gender,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _membershipTile(Membership m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        image: DecorationImage(
          image: AssetImage(m.image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.1),
            BlendMode.darken,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${m.name} Member',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: m.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${formatRupiah(m.price)}/month',
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}
