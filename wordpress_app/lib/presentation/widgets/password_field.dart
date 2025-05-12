import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// A password field widget with a toggle to show/hide the password.
class PasswordField extends StatefulWidget {
  /// The name of the form field.
  final String name;

  /// The label text for the field.
  final String labelText;

  /// The hint text for the field.
  final String hintText;

  /// The validator for the field.
  final String? Function(String?)? validator;

  /// Creates a password field.
  const PasswordField({
    super.key,
    required this.name,
    required this.labelText,
    required this.hintText,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.name,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: const OutlineInputBorder(),
      ),
      obscureText: _obscureText,
      validator: widget.validator,
    );
  }
}
