import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notesCol(String uid) {
    return _db.collection('users').doc(uid).collection('notes');
  }

  Stream<List<NoteModel>> streamNotes(
      String uid, {
        String? tag,
        String? search,
      }) {
    Query<Map<String, dynamic>> q = _notesCol(uid);

    if (tag != null && tag.isNotEmpty) {
      q = q.where('tags', arrayContains: tag);
    } else {
      q = q.orderBy('updatedAt', descending: true);
    }

    return q.snapshots().map((snap) {
      final notes =
      snap.docs.map((d) => NoteModel.fromFirestore(d)).toList();

      final s = (search ?? '').trim().toLowerCase();
      if (s.isEmpty) return notes;

      return notes.where((n) {
        return n.title.toLowerCase().contains(s) ||
            n.content.toLowerCase().contains(s);
      }).toList();
    });
  }

  Future<String> addNote(String uid, NoteModel note) async {
    try {
      final doc = await _notesCol(uid).add(note.toFirestore());
      return doc.id;
    } on FirebaseException catch (e) {
      throw Exception('Falha ao criar nota: ${e.message}');
    } catch (_) {
      throw Exception('Erro ao criar nota');
    }
  }

  Future<NoteModel?> getNote(String uid, String noteId) async {
    try {
      final doc = await _notesCol(uid).doc(noteId).get();
      if (!doc.exists) return null;
      return NoteModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Falha ao obter nota: ${e.message}');
    } catch (_) {
      throw Exception('Erro ao obter nota');
    }
  }

  Future<void> updateNote(
      String uid,
      String noteId,
      Map<String, dynamic> updates,
      ) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _notesCol(uid).doc(noteId).update(updates);
    } on FirebaseException catch (e) {
      throw Exception('Falha ao atualizar nota: ${e.message}');
    } catch (_) {
      throw Exception('Erro ao atualizar nota');
    }
  }

  Future<void> deleteNote(String uid, String noteId) async {
    try {
      await _notesCol(uid).doc(noteId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Falha ao apagar nota: ${e.message}');
    } catch (_) {
      throw Exception('Erro ao apagar nota');
    }
  }
}
