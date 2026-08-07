import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final nameInput = TextEditingController();
  final emailInput = TextEditingController();
  final passInput = TextEditingController();
  final rePassInput = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    nameInput.dispose();
    emailInput.dispose();
    passInput.dispose();
    rePassInput.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final name = nameInput.text.trim();
    final email = emailInput.text.trim();
    final password = passInput.text;

    setState(() => _isLoading = true);
    await auth.register(name: name, email: email, password: password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (auth.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully: $name'),
          duration: const Duration(seconds: 2),
        ),
      );
      nameInput.clear();
      emailInput.clear();
      passInput.clear();
      rePassInput.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameInput,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _fieldDecoration('Full name', 'Please enter your full name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailInput,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: _fieldDecoration('Email', 'Please enter your email'),
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passInput,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _fieldDecoration('Password', 'Please enter your password')
                  .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: rePassInput,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _fieldDecoration(
                'Confirm password',
                'Please enter your password',
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm password cannot be empty';
                }
                if (value != passInput.text) {
                  return 'Password do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'SIGN UP',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      hintText: hint,
      hintStyle: const TextStyle(color: Color.fromARGB(134, 255, 255, 255)),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
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

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }
}
