import 'package:flutter/material.dart';
import '../supabase_config.dart';

class RegisterScreen
    extends
        StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<
    RegisterScreen
  >
  createState() => _RegisterScreenState();
}

class _RegisterScreenState
    extends
        State<
          RegisterScreen
        > {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'customer'; // Default role
  bool _isLoading = false;

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        pass.isEmpty) {
      _showMsg(
        'Please complete all required fields',
      );
      return;
    }
    if (pass !=
        confirmPass) {
      _showMsg(
        'Passwords do not match',
      );
      return;
    }

    setState(
      () => _isLoading = true,
    );
    try {
      final supabase = SupabaseConfig.client;
      final response = await supabase.auth.signUp(
        email: email,
        password: pass,
      );

      final user = response.user;
      if (user !=
          null) {
        final wiivCard = 'WIIV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

        await supabase
            .from(
              'profiles',
            )
            .insert(
              {
                'id': user.id,
                'full_name': name,
                'email': email,
                'role': _selectedRole, // Saves as 'customer' or 'admin'
                'wiiv_card_number': wiivCard,
                'wiiv_points': 100,
              },
            );

        _showMsg(
          'Account registered as $_selectedRole!',
        );
        if (mounted)
          Navigator.pop(
            context,
          );
      }
    } catch (
      e
    ) {
      _showMsg(
        'Registration failed: ${e.toString()}',
      );
    } finally {
      if (mounted)
        setState(
          () => _isLoading = false,
        );
    }
  }

  void _showMsg(
    String msg,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    const winnersGreen = Color(
      0xFF008751,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
        backgroundColor: winnersGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            DropdownButtonFormField<
              String
            >(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.admin_panel_settings_outlined,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'customer',
                  child: Text(
                    'Customer Account',
                  ),
                ),
                DropdownMenuItem(
                  value: 'admin',
                  child: Text(
                    'Admin / Store Manager',
                  ),
                ),
              ],
              onChanged:
                  (
                    val,
                  ) => setState(
                    () => _selectedRole = val!,
                  ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.lock_reset_outlined,
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: winnersGreen,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'REGISTER ACCOUNT',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
