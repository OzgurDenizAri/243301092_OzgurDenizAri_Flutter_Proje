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
    _OgretmenKurslarSekmeli(),
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

class _OgretmenKurslarSekmeli extends StatelessWidget {
  const _OgretmenKurslarSekmeli();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Öğretmen Paneli'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kurslarım', icon: Icon(Icons.menu_book)),
              Tab(text: 'Öğrencilerim', icon: Icon(Icons.groups)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _KurslarimTab(),
            _OgrencilerimTab(),
          ],
        ),
      ),
    );
  }
}

class _KurslarimTab extends StatefulWidget {
  const _KurslarimTab();

  @override
  State<_KurslarimTab> createState() => _KurslarimTabState();
}

class _KurslarimTabState extends State<_KurslarimTab> {
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
    return RefreshIndicator(
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
    );
  }
}

class _OgrencilerimTab extends StatefulWidget {
  const _OgrencilerimTab();

  @override
  State<_OgrencilerimTab> createState() => _OgrencilerimTabState();
}

class _KursOgrenciGrup {
  _KursOgrenciGrup({required this.kursAdi, required this.ogrenciler});

  final String kursAdi;
  final List<String> ogrenciler;
}

class _OgrencilerimTabState extends State<_OgrencilerimTab> {
  late Future<List<_KursOgrenciGrup>> _gruplarFuture;

  @override
  void initState() {
    super.initState();
    _gruplarFuture = _fetchOgrenciler();
  }

  Future<List<_KursOgrenciGrup>> _fetchOgrenciler() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final ogretmen = await supabase
        .from('ogretmen')
        .select('ogretmenid')
        .eq('auth_id', userId)
        .single();
    final ogretmenId = ogretmen['ogretmenid'];

    final kurslarRes = await supabase
        .from('kurs')
        .select('kursid, kursadi')
        .eq('ogretmenid', ogretmenId);
    final kurslar = List<Map<String, dynamic>>.from(kurslarRes);
    if (kurslar.isEmpty) return [];

    final kursIds = kurslar.map((k) => k['kursid']).toList();

    final kayitlarRes = await supabase
        .from('kurskayit')
        .select('kursid, ogrenciid')
        .inFilter('kursid', kursIds);
    final kayitlar = List<Map<String, dynamic>>.from(kayitlarRes);

    final ogrenciIds = kayitlar
        .map((k) => k['ogrenciid'])
        .where((id) => id != null)
        .toSet()
        .toList();

    final Map<dynamic, String> ogrenciAdMap = {};
    if (ogrenciIds.isNotEmpty) {
      final ogrencilerRes = await supabase
          .from('ogrenci')
          .select('ogrenciid, ad, soyad')
          .inFilter('ogrenciid', ogrenciIds);
      for (final o in ogrencilerRes) {
        final ad = (o['ad'] ?? '').toString();
        final soyad = (o['soyad'] ?? '').toString();
        ogrenciAdMap[o['ogrenciid']] = '$ad $soyad'.trim();
      }
    }

    return kurslar.map((kurs) {
      final kursId = kurs['kursid'];
      final kursAdi = (kurs['kursadi'] ?? '').toString();
      final ogrenciler = kayitlar
          .where((k) => k['kursid'] == kursId)
          .map((k) => ogrenciAdMap[k['ogrenciid']] ?? '')
          .where((ad) => ad.isNotEmpty)
          .toList();
      return _KursOgrenciGrup(
        kursAdi: kursAdi.isEmpty ? 'Kurs' : kursAdi,
        ogrenciler: ogrenciler,
      );
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _gruplarFuture = _fetchOgrenciler();
    });
    await _gruplarFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<_KursOgrenciGrup>>(
        future: _gruplarFuture,
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
                    'Öğrenciler yüklenemedi: ${snapshot.error}',
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }
          final gruplar = snapshot.data ?? [];
          if (gruplar.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                Center(child: Text('Henüz öğrenciniz yok')),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: gruplar.length,
            itemBuilder: (context, index) {
              final grup = gruplar[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  leading: const Icon(Icons.menu_book),
                  title: Text(
                    grup.kursAdi,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text('${grup.ogrenciler.length} öğrenci'),
                  children: grup.ogrenciler.isEmpty
                      ? const [
                          ListTile(
                            leading: Icon(Icons.info_outline),
                            title: Text('Kayıtlı öğrenci yok'),
                          ),
                        ]
                      : grup.ogrenciler
                          .map(
                            (ad) => ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(ad),
                            ),
                          )
                          .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
