import 'package:flutter/material.dart';
import '../../core/localization.dart';
import '../../data/api/local_database.dart';
import '../../domain/models/user.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onBackToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
    required this.onBackToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  List<String> _errors = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text;
    final email = _emailCtrl.text;
    final pass = _passCtrl.text;

    if (name.isEmpty) {
      setState(() => _errors = ['Name is required']);
      return;
    }

    final collected = <String>[];
    if (!email.contains('@')) collected.add('Invalid email format');
    if (pass.length < 6) collected.add('Password must be at least 6 characters');

    if (collected.isNotEmpty) {
      setState(() => _errors = collected);
      return;
    }

    setState(() => _errors = []);
      final existing = LocalDatabase.instance.getUser();
      final updated = existing?.copyWith(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text,
        email: _emailCtrl.text,
      ) ?? User(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        goal: GoalType.conditioning,
      );
      await LocalDatabase.instance.saveUser(updated);
    widget.onRegisterSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                key: const Key('register_name_field'),
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('register_email_field'),
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('register_password_field'),
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Password'),
              ),
              if (_errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._errors.map(
                  (e) => Text(e, style: const TextStyle(color: Color(0xFFE94560))),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  key: const Key('register_submit_btn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(AppLocalizations.get('register'), style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                key: const Key('register_back_to_login_btn'),
                onPressed: widget.onBackToLogin,
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: const Color(0xFF16213E),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
