import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class OgretmenAnaSayfa extends StatefulWidget {
  const OgretmenAnaSayfa({super.key});

  @override
  State<OgretmenAnaSayfa> createState() => _OgretmenAnaSayfaState();
}

class _OgretmenAnaSayfaState extends State<OgretmenAnaSayfa> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    _OgretmenKurslarTab(),
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

class _OgretmenKurslarTab extends StatefulWidget {
  const _OgretmenKurslarTab();

  @override
  State<_OgretmenKurslarTab> createState() => _OgretmenKurslarTabState();
}

class _OgretmenKurslarTabState extends State<_OgretmenKurslarTab> {
  late Future<List<Map<String, dynamic>>> _kurslarFuture;

  @override
  void initState() {
    super.initState();
    _kurslarFuture = _fetchKurslar();
  }

  Future<List<Map<String, dynamic>>> _fetchKurslar() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final ogretmen = await supabase
        .from('ogretmen')
        .select('ogretmenid')
        .eq('auth_id', userId)
        .single();
    final ogretmenId = ogretmen['ogretmenid'];

    final res = await supabase
        .from('kurs')
        .select('kursid, kursadi, seviye, dil(diladi)')
        .eq('ogretmenid', ogretmenId);
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
      appBar: AppBar(title: const Text('Kurslarım')),
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
                  Center(child: Text('Henüz kursunuz yok')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: kurslar.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final kurs = kurslar[index];
                final kursadi = (kurs['kursadi'] ?? '').toString();
                final seviye = (kurs['seviye'] ?? '').toString();
                final diladi = (kurs['dil']?['diladi'] ?? '').toString();
                final altBaslik = [
                  if (diladi.isNotEmpty) diladi,
                  if (seviye.isNotEmpty) seviye,
                ].join(' • ');
                return ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(kursadi.isEmpty ? 'Kurs' : kursadi),
                  subtitle: altBaslik.isEmpty ? null : Text(altBaslik),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
