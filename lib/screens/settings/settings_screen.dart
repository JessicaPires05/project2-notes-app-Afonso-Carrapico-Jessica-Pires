import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Definições')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SwitchListTile(
              value: settings.isDark,
              onChanged: (v) => context.read<SettingsProvider>().toggleDark(v),
              title: const Text('Modo escuro'),
            ),
            const SizedBox(height: 12),
            const Text('Cor principal:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _dot(context, Colors.indigo),
                _dot(context, Colors.teal),
                _dot(context, Colors.deepPurple),
                _dot(context, Colors.orange),
                _dot(context, Colors.pink),
                _dot(context, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(BuildContext context, Color c) {
    return InkWell(
      onTap: () => context.read<SettingsProvider>().setSeed(c),
      child: CircleAvatar(backgroundColor: c, radius: 14),
    );
  }
}
