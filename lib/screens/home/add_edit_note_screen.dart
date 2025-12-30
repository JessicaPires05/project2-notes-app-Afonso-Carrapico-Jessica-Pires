import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../providers/data_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/image_helper.dart';
import '../../utils/validators.dart';


class AddEditNoteScreen extends StatefulWidget {
  final String? noteId;
  const AddEditNoteScreen({super.key, this.noteId});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();

  String _tag = 'Personal';
  GeoPoint? _location;

  bool _loading = false;


  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      _loadNote();
    }
  }

  Future<void> _loadNote() async {
    final data = context.read<DataProvider>();
    final note = await data.getNote(widget.noteId!);
    if (note == null) return;

    setState(() {
      _title.text = note.title;
      _content.text = note.content;
      _tag = note.tags.isNotEmpty ? note.tags.first : 'Personal';
      _location = note.location;
      _images.addAll(note.imagesBase64);
    });
  }



  Future<void> _pickGallery() async {
    try {
      final file = await context.read<DataProvider>().pickGallery();
      if (file == null) return;
      _images.add(await fileToBase64(file));
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    }
  }

  Future<void> _takePhoto() async {
    try {
      final file = await context.read<DataProvider>().takeCamera();
      if (file == null) return;
      _images.add(await fileToBase64(file));
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    }
  }


  Future<void> _getLocation() async {
    setState(() => _loading = true);
    try {
      final gp = await context.read<DataProvider>().getCurrentGeoPoint();
      setState(() => _location = gp);
      if (!mounted) return;
      showSnack(context, 'Localização guardada.');
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  Future<void> _citation() async {
    try {
      final res = await http.get(Uri.parse('https://type.fit/api/quotes'));
      final List data = res.statusCode == 200
          ? json.decode(res.body)
          : [
        {"text": "Não desistas.", "author": "Autor desconhecido"},
        {"text": "Cada dia é uma nova oportunidade.", "author": "Autor desconhecido"},
      ];

      final q = (data..shuffle()).first;
      final quote = '${q['text']} — ${q['author'] ?? 'Autor desconhecido'}';

      setState(() {
        _content.text = (_content.text + '\n\n' + quote).trim();
      });
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    }
  }


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final data = context.read<DataProvider>();

    try {
      final titleTrimmed = _title.text.trim();
      final contentTrimmed = _content.text.trim();

      if (widget.noteId == null) {

        await data.createNoteWithImages(
          title: titleTrimmed,
          content: contentTrimmed,
          tags: [_tag],
          location: _location,
          imagesBase64: _images,
        );


        if (!mounted) return;
        showSnack(context, 'Nota criada.');
      } else {

        await data.updateNote(widget.noteId!, {
          'title': titleTrimmed,
          'content': contentTrimmed,
          'tags': [_tag],
          'location': _location,
          'imagesBase64': _images,
          'updatedAt': Timestamp.now(),
        });

        if (!mounted) return;
        showSnack(context, 'Nota atualizada.');
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isEdit = widget.noteId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Nota' : 'Nova Nota')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => Validators.nonEmpty(v, 'Título'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _content,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Conteúdo *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    (v ?? '').trim().length < 5 ? 'Mínimo 5 caracteres' : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _tag,
                    decoration: const InputDecoration(
                      labelText: 'Tag *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                      DropdownMenuItem(value: 'School', child: Text('School')),
                      DropdownMenuItem(value: 'Work', child: Text('Work')),
                    ],
                    onChanged: (v) => setState(() => _tag = v ?? 'Personal'),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickGallery,
                        icon: const Icon(Icons.photo),
                        label: const Text('Galeria'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Câmara'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _getLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('GPS'),
                      ),
                    ],
                  ),

                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Imagens anexadas:'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(_images[i]),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _citation,
                    icon: const Icon(Icons.format_quote),
                    label: const Text('Sugestão de citação'),
                  ),

                  const SizedBox(height: 16),
                  OverflowBar(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: _save,
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color.fromARGB(80, 0, 0, 0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
