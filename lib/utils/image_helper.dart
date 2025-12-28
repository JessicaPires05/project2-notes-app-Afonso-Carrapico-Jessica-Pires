import 'dart:convert';
import 'dart:io';

Future<String> fileToBase64(File file) async {
  final bytes = await file.readAsBytes();
  return base64Encode(bytes);
}