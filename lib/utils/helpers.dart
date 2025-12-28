import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Erro'),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ],
    ),
  );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
