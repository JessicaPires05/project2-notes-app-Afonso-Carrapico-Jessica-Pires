import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class NativeService {
  final _picker = ImagePicker();

  Future<File?> pickFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x == null) return null;
    return _compress(File(x.path));
  }

  Future<File?> takePhoto() async {
    final x = await _picker.pickImage(source: ImageSource.camera);
    if (x == null) return null;
    return _compress(File(x.path));
  }

  Future<File?> _compress(File file) async {
    final outPath = '${file.path}_compressed.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 75,
    );

    if (result == null) return file;

    return File(result.path);
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1️⃣ Verifica se o GPS está ligado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desligado.');
    }

    // 2️⃣ Verifica permissões
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização negada permanentemente. '
            'Ativa nas definições do sistema.',
      );
    }

    // 3️⃣ Obtém localização
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
