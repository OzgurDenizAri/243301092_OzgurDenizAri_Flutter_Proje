import 'package:flutter/material.dart';

class DerslerScreen extends StatelessWidget {
  const DerslerScreen({super.key});

  static const _dersler = [
    'İngilizce',
    'Almanca',
    'Fransızca',
    'İspanyolca',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dersler')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _dersler.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final baslik = _dersler[index];
          return ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(baslik),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$baslik dersi yakında!')),
              );
            },
          );
        },
      ),
    );
  }
}
