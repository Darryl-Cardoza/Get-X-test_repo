// lib/global_widgets/form_input_field.dart

import 'package:flutter/material.dart';

/// A reusable form input field that wraps [TextFormField] with consistent styling,
/// validation, and optional icon toggles (e.g., password visibility).
class FormInputField extends StatelessWidget {
  /// Controller for managing the text input.
  final TextEditingController controller;

  /// The keyboard action (e.g., next, done).
  final TextInputAction textInputAction;

  /// The label displayed above the field.
  final String label;

  /// Input type (e.g., email, text, number).
  final TextInputType keyboardType;

  /// Whether the input should obscure text (password fields).
  final bool obscureText;

  /// Validator callback returning an error message or null.
  final String? Function(String?)? validator;

  /// Optional prefix icon inside the input field.
  final IconData? prefixIcon;

  /// Optional suffix icon (e.g., visibility toggle) inside the input.
  final Widget? suffixIcon;

  const FormInputField({
    Key? key,
    required this.controller,
    required this.label,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.labelMedium,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: theme.colorScheme.primary)
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
      validator: validator,
    );
  }
}
