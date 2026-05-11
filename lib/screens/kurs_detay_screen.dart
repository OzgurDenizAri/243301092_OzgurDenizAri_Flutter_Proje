import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/islem_log.dart';

class KursDetayScreen extends StatefulWidget {
  const KursDetayScreen({super.key, required this.kurs});

  final Map<String, dynamic> kurs;

  @override
  State<KursDetayScreen> createState() => _KursDetayScreenState();
}

class _KursDetayScreenState extends State<KursDetayScreen> {
  bool _kayitYapiliyor = false;
  String? _mesaj;
  bool _basarili = false;

  Future<void> _kayitOl() async {
    setState(() {
      _kayitYapiliyor = true;
      _mesaj = null;
      _basarili = false;
    });

    final supabase = Supabase.instance.client;
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw 'Oturum bulunamadı';

      final ogrenci = await supabase
          .from('ogrenci')
          .select('ogrenciid')
          .eq('auth_id', userId)
          .single();

      await supabase.from('kurskayit').insert({
        'kursid': widget.kurs['kursid'],
        'ogrenciid': ogrenci['ogrenciid'],
      });

      await kaydetIslemLog(
        islem: 'kursa_kayit',
        tabloAdi: 'kurskayit',
        aciklama: (widget.kurs['kursadi'] ?? '').toString(),
      );

      if (!mounted) return;
      setState(() {
        _mesaj = 'Kursa başarıyla kayıt oldun';
        _basarili = true;
      });
    } on PostgrestException catch (e) {
      setState(() => _mesaj = e.message);
    } catch (e) {
      setState(() => _mesaj = e.toString());
    } finally {
      if (mounted) setState(() => _kayitYapiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kurs = widget.kurs;
    final kursadi = (kurs['kursadi'] ?? 'Kurs').toString();
    final seviye = (kurs['seviye'] ?? '').toString();
    final diladi = (kurs['dil']?['diladi'] ?? '').toString();
    final ogretmen = kurs['ogretmen'] as Map<String, dynamic>?;
    final ogretmenAdSoyad = ogretmen == null
        ? ''
        : '${ogretmen['ad'] ?? ''} ${ogretmen['soyad'] ?? ''}'.trim();

    return Scaffold(
      appBar: AppBar(title: Text(kursadi)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kursadi, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  if (diladi.isNotEmpty)
                    _DetayRow(icon: Icons.language, label: 'Dil', value: diladi),
                  if (seviye.isNotEmpty)
                    _DetayRow(icon: Icons.bar_chart, label: 'Seviye', value: seviye),
                  if (ogretmenAdSoyad.isNotEmpty)
                    _DetayRow(
                      icon: Icons.person,
                      label: 'Öğretmen',
                      value: ogretmenAdSoyad,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_mesaj != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _mesaj!,
                style: TextStyle(
                  color: _basarili
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_kayitYapiliyor || _basarili) ? null : _kayitOl,
              icon: const Icon(Icons.app_registration),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _kayitYapiliyor
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_basarili ? 'Kayıt Tamamlandı' : 'Kursa Kayıt Ol'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetayRow extends StatelessWidget {
  const _DetayRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
