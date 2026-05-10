import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kurs_detay_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class OgrenciAnaSayfa extends StatefulWidget {
  const OgrenciAnaSayfa({super.key});

  @override
  State<OgrenciAnaSayfa> createState() => _OgrenciAnaSayfaState();
}

class _OgrenciAnaSayfaState extends State<OgrenciAnaSayfa> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    _OgrenciKurslarTab(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Kurslar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}

class _OgrenciKurslarTab extends StatefulWidget {
  const _OgrenciKurslarTab();

  @override
  State<_OgrenciKurslarTab> createState() => _OgrenciKurslarTabState();
}

class _OgrenciKurslarTabState extends State<_OgrenciKurslarTab> {
  late Future<List<Map<String, dynamic>>> _kurslarFuture;

  @override
  void initState() {
    super.initState();
    _kurslarFuture = _fetchKurslar();
  }

  Future<List<Map<String, dynamic>>> _fetchKurslar() async {
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('kurs')
        .select('kursid, kursadi, seviye, dil(diladi), ogretmen(ad, soyad)');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> _refresh() async {
    setState(() {
      _kurslarFuture = _fetchKurslar();
    });
    await _kurslarFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kurslar')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _kurslarFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Kurslar yüklenemedi: ${snapshot.error}',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            final kurslar = snapshot.data ?? [];
            if (kurslar.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('Henüz kurs yok')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: kurslar.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final kurs = kurslar[index];
                final kursadi = (kurs['kursadi'] ?? 'Kurs').toString();
                final seviye = (kurs['seviye'] ?? '').toString();
                final diladi = (kurs['dil']?['diladi'] ?? '').toString();
                final ogretmen = kurs['ogretmen'] as Map<String, dynamic>?;
                final ogretmenAdSoyad = ogretmen == null
                    ? ''
                    : '${ogretmen['ad'] ?? ''} ${ogretmen['soyad'] ?? ''}'.trim();
                final altBaslik = [
                  if (diladi.isNotEmpty) diladi,
                  if (seviye.isNotEmpty) seviye,
                  if (ogretmenAdSoyad.isNotEmpty) ogretmenAdSoyad,
                ].join(' • ');
                return ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(kursadi),
                  subtitle: altBaslik.isEmpty ? null : Text(altBaslik),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KursDetayScreen(kurs: kurs),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
