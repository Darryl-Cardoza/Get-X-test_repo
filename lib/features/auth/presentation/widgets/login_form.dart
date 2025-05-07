// lib/features/auth/presentation/widgets/login_form.dart

import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../global_widgets/form_input_field.dart';

/// A stateful login form leveraging ThemeData, form validation, and a reusable input widget.
class LoginForm extends StatefulWidget {
  /// Called when form is valid and user taps "Login".
  final void Function(String email, String password) onSubmit;

  const LoginForm({super.key, required this.onSubmit});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Email field validator using [Validators.isEmail].
  String? _validateEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email cannot be empty';
    if (!Validators.isEmail(input)) return 'Please enter a valid email';
    return null;
  }

  /// Password field validator using [Validators.isStrongPassword].
  String? _validatePassword(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Password cannot be empty';
    if (!Validators.isStrongPassword(input)) {
      return 'Password must be at least 8 characters and include uppercase, lowercase, digit, and special char';
    }
    return null;
  }

  /// Validates inputs and invokes onSubmit if valid.
  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reusable email input field
            FormInputField(
              controller: _emailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              prefixIcon: Icons.email,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            FormInputField(
              controller: _passCtrl,
              label: 'Password',
              obscureText: _obscurePassword,
              validator: _validatePassword,
              prefixIcon: Icons.lock,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
