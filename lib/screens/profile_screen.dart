import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/islem_log.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final email = supabase.auth.currentUser?.email ?? '';
    await kaydetIslemLog(
      islem: 'cikis',
      tabloAdi: 'auth',
      aciklama: email,
    );
    await supabase.auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 56,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              email,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('E-posta'),
            subtitle: Text(email.isEmpty ? 'eklenmedi' : email),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap'),
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
