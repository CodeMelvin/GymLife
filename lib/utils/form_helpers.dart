import 'package:flutter/material.dart';

InputDecoration fieldDecoration(
  String label,
  String hint, {
  double verticalPadding = 15,
  BorderSide enabledBorderSide = const BorderSide(color: Colors.white),
}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.1),
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white),
    hintText: hint,
    hintStyle: const TextStyle(color: Color.fromARGB(134, 255, 255, 255)),
    contentPadding: EdgeInsets.symmetric(
      vertical: verticalPadding,
      horizontal: 16,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: enabledBorderSide,
      borderRadius: BorderRadius.circular(16),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(16),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(16),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(16),
    ),
    errorStyle: const TextStyle(color: Colors.redAccent),
  );
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email cannot be empty';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Invalid email format';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password cannot be empty';
  }
  if (value.length < 4) {
    return 'Password must be at least 4 characters';
  }
  return null;
}
