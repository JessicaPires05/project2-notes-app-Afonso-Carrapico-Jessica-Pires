import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/native_service.dart';
import '../services/api_service.dart';
import '../utils/image_helper.dart';

class DataProvider extends ChangeNotifier {
  final _firestore = FirestoreService();
  final _storage = StorageService();
  final _native = NativeService();
  final _api = ApiService();

  User? _user;

  String _selectedTag = '';
  String get selectedTag => _selectedTag;
  set selectedTag(String v) {
    _selectedTag = v;
    notifyListeners();
  }

  String _search = '';
  String get search => _search;
  set search(String v) {
    _search = v;
    notifyListeners();
  }

  void setUser(User? u) {
    _user = u;
    notifyListeners();
  }

  String get _uid {
    final uid = _user?.uid;
    if (uid == null) throw Exception('Utilizador não autenticado.');
    return uid;
  }

  Stream<List<NoteModel>> get notesStream =>
      _firestore.streamNotes(_uid, tag: _selectedTag, search: _search);

  Future<NoteModel?> getNote(String id) => _firestore.getNote(_uid, id);

  Future<String> createNote({
    required String title,
    required String content,
    required List<String> tags,
    GeoPoint? location,
  }) async {
    final now = Timestamp.now();
    final note = NoteModel(
      id: '',
      title: title,
      content: content,
      tags: tags,
      imagesBase64: [],
      createdAt: now,
      updatedAt: now,
      location: location,
    );
    return _firestore.addNote(_uid, note);
  }

  Future<String> createNoteWithImages({
    required String title,
    required String content,
    required List<String> tags,
    GeoPoint? location,
    required List<String> imagesBase64,
  }) async {
    final now = Timestamp.now();

    final note = NoteModel(
      id: '',
      title: title,
      content: content,
      tags: tags,
      imagesBase64: imagesBase64,
      createdAt: now,
      updatedAt: now,
      location: location,
    );

    return _firestore.addNote(_uid, note);
  }


  Future<void> addImageToNote({
    required String noteId,
    required File file,
  }) async {

    final base64Image = await fileToBase64(file);


    final note = await _firestore.getNote(_uid, noteId);
    if (note == null) {
      throw Exception('Nota não encontrada');
    }


    final newImages = [...note.imagesBase64, base64Image];


    await _firestore.updateNote(_uid, noteId, {
      'imagesBase64': newImages,
    });
  }


  Future<void> updateNote(String noteId, Map<String, dynamic> updates) =>
      _firestore.updateNote(_uid, noteId, updates);

  Future<GeoPoint> getCurrentGeoPoint() async {
    final pos = await _native.getCurrentLocation();
    return GeoPoint(pos.latitude, pos.longitude);
  }

  Future<File?> pickGallery() => _native.pickFromGallery();
  Future<File?> takeCamera() => _native.takePhoto();

  Future<(String url, String path)> uploadNoteImage({
    required String noteId,
    required File file,
    required String filename,
  }) async {
    final path = 'users/$_uid/notes/$noteId/$filename';
    final url = await _storage.uploadImage(path: path, file: file);
    return (url, path);
  }



  Future<void> deleteNoteWithCleanup(NoteModel note) async {

    await _firestore.deleteNote(_uid, note.id);
    notifyListeners();
  }

  Future<String> dailyQuoteText() async {
    final q = await _api.getDailyQuoteCached();
    return '${q.content} — ${q.author}';
  }

  Future<List<QuoteResult>> searchQuotes(String query) async {
    final list = await _api.searchQuotes(query);
    return list
        .map((q) => QuoteResult(id: q.id, text: '${q.content} — ${q.author}'))
        .toList();
  }

  Future<String> quoteDetailsText(String id) async {
    final q = await _api.getQuoteDetails(id);
    return '${q.content} — ${q.author}';
  }
}

class QuoteResult {
  final String id;
  final String text;
  QuoteResult({required this.id, required this.text});
}
