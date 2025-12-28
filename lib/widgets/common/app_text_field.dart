import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscure;
  final int maxLines;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.obscure = false,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon,
      ),
    );
  }
}
