import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required String path,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Falha no upload: ${e.message}');
    }
  }

  Future<void> deleteByPath(String path) async {
    await _storage.ref().child(path).delete();
  }
}
