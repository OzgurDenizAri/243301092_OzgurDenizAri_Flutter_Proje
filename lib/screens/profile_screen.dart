import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              username,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('E-posta'),
            subtitle: Text('eklenmedi'),
          ),
          const ListTile(
            leading: Icon(Icons.school_outlined),
            title: Text('Seviye'),
            subtitle: Text('Başlangıç'),
          ),
          const ListTile(
            leading: Icon(Icons.emoji_events_outlined),
            title: Text('Tamamlanan Dersler'),
            subtitle: Text('0'),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap'),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
