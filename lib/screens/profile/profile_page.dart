import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../auth/auth_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  static const _adminEmail = 'admin@gmail.com';

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    final rootContext = context;
    final profile = context.watch<ProfileProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF060F3F),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF242A63),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profile.imageBytes != null
                            ? MemoryImage(profile.imageBytes!)
                            : null,
                        backgroundColor: Colors.white24,
                        child: profile.imageBytes == null
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.name.isNotEmpty
                          ? profile.name
                          : (auth.currentUserName ?? 'User'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profile.gender.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            profile.gender.toLowerCase() == 'male'
                                ? Icons.male
                                : Icons.female,
                            color: profile.gender.toLowerCase() == 'male'
                                ? Colors.lightBlueAccent
                                : Colors.pinkAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.gender,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      profile.description.isEmpty
                          ? 'Add Description'
                          : profile.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (profile.membershipName.isNotEmpty &&
                  profile.membershipEndDate != null)
                _membershipCard(
                  profile.membershipName,
                  _formatDate(profile.membershipEndDate!),
                )
              else
                const Text(
                  'No active membership yet',
                  style: TextStyle(color: Colors.white54),
                ),
              const SizedBox(height: 20),
              _buildWideButton('Edit Profile', Icons.edit, (ctx) {
                _openEditProfile(ctx, rootContext);
              }),
              const SizedBox(height: 12),
              _buildWideButton('Change Password', Icons.lock, (ctx) {
                _openChangePassword(ctx, rootContext);
              }),
              const SizedBox(height: 12),
              _buildWideButton('Contact Us', Icons.mail_outline, (ctx) {
                _openContactUs(ctx, rootContext);
              }),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  auth.logout();
                  await context.read<ProfileProvider>().logoutProfileKeepData();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _membershipCard(String name, String date) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF242A63),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(
              'Valid until $date',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );

  Widget _buildWideButton(
    String text,
    IconData icon,
    void Function(BuildContext) onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: () => onPressed(context),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F2983),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      await context
          .read<ProfileProvider>()
          .updateProfileImage(await picked.readAsBytes());
    }
  }

  void _openEditProfile(BuildContext context, BuildContext rootContext) {
    final profile = context.read<ProfileProvider>();
    final nameCtrl = TextEditingController(text: profile.name);
    final descCtrl = TextEditingController(text: profile.description);
    String gender = profile.gender;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color(0xFF242A63),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _dialogInputStyle('Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _dialogInputStyle('Description'),
          ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: gender.isEmpty ? null : gender,
              dropdownColor: const Color(0xFF313986),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (v) => gender = v ?? '',
              decoration: _dialogInputStyle('Gender'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await profile.updateName(nameCtrl.text);
                await profile.updateDescription(descCtrl.text);
                await profile.updateGender(gender);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B6CB7),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _openChangePassword(BuildContext context, BuildContext rootContext) {
    final auth = context.read<AuthProvider>();
    final email = context.read<ProfileProvider>().email;
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _buildDialog(
        title: 'Change Password',
        children: [
          _ObscuredTextField(label: 'Old Password', controller: oldCtrl),
          const SizedBox(height: 10),
          _ObscuredTextField(label: 'New Password', controller: newCtrl),
          const SizedBox(height: 10),
          _ObscuredTextField(
            label: 'Confirm New Password',
            controller: confirmCtrl,
          ),
        ],
        onSave: () async {
          if (newCtrl.text.length < 4) {
            ScaffoldMessenger.of(rootContext).showSnackBar(
              const SnackBar(
                content: Text('Password must be at least 4 characters'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          if (newCtrl.text != confirmCtrl.text) {
            ScaffoldMessenger.of(rootContext).showSnackBar(
              const SnackBar(
                content: Text('Passwords do not match'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          await auth.changePassword(
            email: email,
            oldPassword: oldCtrl.text,
            newPassword: newCtrl.text,
          );
          if (!ctx.mounted) return;
          Navigator.pop(ctx);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final message =
                auth.errorMessage ?? 'Password changed successfully';
            ScaffoldMessenger.of(rootContext).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        },
      ),
    );
  }

  void _openContactUs(BuildContext context, BuildContext rootContext) {
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _buildDialog(
        title: 'Contact Us',
        children: [
          TextField(
            enabled: false,
            controller: TextEditingController(text: _adminEmail),
            style: const TextStyle(color: Colors.white),
            decoration: _dialogInputStyle('Email').copyWith(
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _textField('Message', msgCtrl, maxLines: 3),
        ],
        onSave: () {
          if (msgCtrl.text.isEmpty) {
            ScaffoldMessenger.of(rootContext).showSnackBar(
              const SnackBar(
                content: Text('Please enter your message'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(rootContext).showSnackBar(
              SnackBar(
                content: Text('Message sent to $_adminEmail'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController c, {
    int maxLines = 1,
  }) =>
      TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: _dialogInputStyle(label),
      );

  Widget _buildDialog({
    required String title,
    required List<Widget> children,
    required VoidCallback onSave,
  }) {
    return AlertDialog(
      backgroundColor: const Color(0xFF242A63),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: children),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4B6CB7),
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _ObscuredTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const _ObscuredTextField({required this.label, required this.controller});

  @override
  State<_ObscuredTextField> createState() => _ObscuredTextFieldState();
}

class _ObscuredTextFieldState extends State<_ObscuredTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _isObscured,
      style: const TextStyle(color: Colors.white),
      decoration: _dialogInputStyle(widget.label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: () => setState(() => _isObscured = !_isObscured),
        ),
      ),
    );
  }
}

InputDecoration _dialogInputStyle(String label) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: const Color(0xFF313986),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white70),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
