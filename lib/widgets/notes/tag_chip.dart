import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String text;
  const TagChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(text));
  }
}
