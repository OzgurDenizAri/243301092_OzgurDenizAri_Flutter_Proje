import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bildirimler = false;
  bool _karanlikMod = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Bildirimler'),
            value: _bildirimler,
            onChanged: (v) => setState(() => _bildirimler = v),
          ),
          SwitchListTile(
            title: const Text('Karanlık Mod'),
            value: _karanlikMod,
            onChanged: (v) => setState(() => _karanlikMod = v),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Hakkında'),
            subtitle: Text('Arı Yabancı Dil • v0.1'),
          ),
        ],
      ),
    );
  }
}
