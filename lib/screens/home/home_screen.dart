import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/data_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_message.dart';
import '../../widgets/notes/note_card.dart';

import 'add_edit_note_screen.dart';
import 'detail_note_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _dailyQuote = '';

  @override
  void initState() {
    super.initState();
    _loadDailyQuote();
  }

  Future<void> _loadDailyQuote() async {
    try {
      final text = await context.read<DataProvider>().dailyQuoteText();
      if (mounted) setState(() => _dailyQuote = text);
    } catch (_) {
      // ignora
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_dailyQuote.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_dailyQuote),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => data.search = v,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: data.selectedTag.isEmpty ? null : data.selectedTag,
                  hint: const Text('Tag'),
                  items: const [
                    DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                    DropdownMenuItem(value: 'School', child: Text('School')),
                    DropdownMenuItem(value: 'Work', child: Text('Work')),
                  ],
                  onChanged: (v) => data.selectedTag = v ?? '',
                ),
                if (data.selectedTag.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => data.selectedTag = '',
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder(
              stream: data.notesStream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator(label: 'A carregar...');
                }
                if (snap.hasError) {
                  return ErrorMessage(message: 'Erro: ${snap.error}');
                }
                final notes = (snap.data ?? []) as List;
                if (notes.isEmpty) {
                  return const ErrorMessage(message: 'Ainda não há notas. Cria uma no botão +');
                }

                return ListView.separated(
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final note = notes[i];
                    return NoteCard(
                      note: note,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailNoteScreen(noteId: note.id)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova nota'),
      ),
    );
  }
}
