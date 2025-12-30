import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/data_provider.dart';
import '../../models/note_model.dart';
import '../../utils/helpers.dart';
import 'add_edit_note_screen.dart';



class DetailNoteScreen extends StatelessWidget {
  final String noteId;
  const DetailNoteScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();

    return FutureBuilder<NoteModel?>(
      future: data.getNote(noteId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError || snap.data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Nota não encontrada.')),
          );
        }

        final note = snap.data!;
        final created = note.createdAt.toDate();
        final updated = note.updatedAt.toDate();

        return Scaffold(
          appBar: AppBar(
            title: Text(note.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditNoteScreen(noteId: note.id),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Eliminar nota?'),
                      content: const Text('Esta ação não pode ser desfeita.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  try {
                    await data.deleteNoteWithCleanup(note);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorDialog(context, e.toString());
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...note.tags.map((t) => Chip(label: Text(t))),
                    Chip(
                      label: Text(
                        'Criada: ${created.day}/${created.month}/${created.year}',
                      ),
                    ),
                    Chip(
                      label: Text(
                        'Atualizada: ${updated.day}/${updated.month}/${updated.year}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: 16),

                if (note.location != null)
                  Text(
                    'Localização: '
                        '${note.location!.latitude}, '
                        '${note.location!.longitude}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                const SizedBox(height: 16),

                if (note.imagesBase64.isNotEmpty) ...[
                  const Text(
                    'Imagens',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: note.imagesBase64.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final base64Str = note.imagesBase64[i];
                        final bytes = base64Decode(base64Str);

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
