import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> kaydetIslemLog({
  required String islem,
  required String tabloAdi,
  required String aciklama,
}) async {
  final supabase = Supabase.instance.client;
  try {
    await supabase.from('islemlog').insert({
      'kullanici_id': supabase.auth.currentUser?.id,
      'islem': islem,
      'tablo_adi': tabloAdi,
      'aciklama': aciklama,
    });
  } catch (_) {
  }
}
