import 'package:flutter/material.dart';
import '../../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dt = note.updatedAt.toDate();
    final dateStr = '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';

    return ListTile(
      title: Text(note.title.isEmpty ? '(Sem título)' : note.title),
      subtitle: Text(
        note.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(dateStr, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 6),

        ],
      ),
      onTap: onTap,
    );
  }
}
