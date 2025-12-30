import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final List<String> imagesBase64;
  final GeoPoint? location;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.imagesBase64,
    required this.createdAt,
    required this.updatedAt,
    this.location,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NoteModel(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      content: (data['content'] ?? '') as String,
      tags: List<String>.from(data['tags'] ?? const []),
      imagesBase64: List<String>.from(data['imagesBase64'] ?? []),
      location: data['location'] as GeoPoint?,
      createdAt: (data['createdAt'] ?? Timestamp.now()) as Timestamp,
      updatedAt: (data['updatedAt'] ?? Timestamp.now()) as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'content': content,
    'tags': tags,
    'imagesBase64': imagesBase64,
    'location': location,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
