import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/ogrenci_ana_sayfa.dart';
import 'screens/ogretmen_ana_sayfa.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://flrolezyzgrkserzcpek.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZscm9sZXp5emdya3NlcnpjcGVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgzNTMwMjYsImV4cCI6MjA5MzkyOTAyNn0.Doh7D5fY7IE5SdORNMTyEmcd82qI_UPAtMs9skPJHoo',
  );

  final initialScreen = await _resolveInitialScreen();
  runApp(AriYabanciDilApp(home: initialScreen));
}

Future<Widget> _resolveInitialScreen() async {
  final supabase = Supabase.instance.client;
  final session = supabase.auth.currentSession;
  if (session == null) return const LoginScreen();

  try {
    final profile = await supabase
        .from('profiller')
        .select('rol')
        .eq('id', session.user.id)
        .single();
    final rol = profile['rol'] as String?;
    if (rol == 'ogrenci') return const OgrenciAnaSayfa();
    if (rol == 'ogretmen') return const OgretmenAnaSayfa();
  } catch (_) {
    await supabase.auth.signOut();
  }
  return const LoginScreen();
}

class AriYabanciDilApp extends StatelessWidget {
  const AriYabanciDilApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arı Yabancı Dil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB300)),
        useMaterial3: true,
      ),
      home: home,
    );
  }
}
