import 'package:flutter/material.dart';

class Membership {
  final int id;
  final String name;
  final String description;
  final int price;
  final Color color;
  final List<String> benefits;
  final String image;

  const Membership({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.color,
    required this.benefits,
    required this.image,
  });

  Color get accentColor {
    switch (name.toLowerCase()) {
      case 'silver':
        return const Color(0xFF8A8A8A);
      case 'gold':
        return const Color(0xFFFFC107);
      case 'platinum':
        return const Color(0xFF7E8B92);
      default:
        return Colors.blueGrey;
    }
  }
}

const List<Membership> kMemberships = [
  Membership(
    id: 1,
    name: 'Silver',
    description: 'Basic membership with standard facilities.',
    price: 500000,
    color: Color.fromARGB(225, 255, 255, 255),
    benefits: ['Free Parking', 'Personal Locker'],
    image: 'images/silver.png',
  ),
  Membership(
    id: 2,
    name: 'Gold',
    description: 'Intermediate membership with extra 2x training.',
    price: 1000000,
    color: Color.fromARGB(255, 255, 215, 0),
    benefits: ['Free Parking', 'Personal Locker', '2 Times Trainer'],
    image: 'images/gold.png',
  ),
  Membership(
    id: 3,
    name: 'Platinum',
    description: 'Exclusive membership with all complete facilities.',
    price: 1500000,
    color: Color.fromARGB(255, 117, 117, 117),
    benefits: [
      'Free Parking',
      'Personal Locker',
      'VIP Gym Room',
      '4 Times Trainer',
    ],
    image: 'images/platinum.png',
  ),
];
