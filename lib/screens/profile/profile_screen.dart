import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final providers = user?.providerData.map((p) => p.providerId).toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(user?.email ?? 'Sem email'),
              subtitle: Text('UID: ${user?.uid ?? '-'}'),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Providers'),
              subtitle: Text(providers.isEmpty ? 'Desconhecido' : providers.join(', ')),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                try {
                  await context.read<AuthProvider>().signOut();
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorDialog(context, e.toString());
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Terminar sessão'),
            ),
          ],
        ),
      ),
    );
  }
}
