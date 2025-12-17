import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:ebucare_app/auth/auth_gate.dart';
import 'package:ebucare_app/service/noti_service.dart';
import 'package:ebucare_app/pages/reset_password_page.dart'; // ✅ ADD THIS
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://jutjsmxfctcvvrhmvlgt.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1dGpzbXhmY3RjdnZyaG12bGd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4OTY2MzMsImV4cCI6MjA2MTQ3MjYzM30.bdSIKduNEvY0T1yh8JHFwIu1wBYdhbHQ8khH2APcBrs",
  );

  final notiService = NotiService();
  await notiService.initNotification();

  if (!kIsWeb) {
    Stripe.publishableKey =
        "pk_test_51SdT7SKp4XOhFa4a8kJ03oOsKegaxIApUD4OfV3GsP1XrxiCOAr5GJtxQBX7IPaBxm8st9A2HOrIJYSWkcW6ARlt007XgbzHaU";
    await Stripe.instance.applySettings();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<AuthState> _authSub;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();

    // keep your auth listener if you want
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
      }
    });

    // ✅ NEW: handle deep links from email/browser
    _handleIncomingLinks();
  }

  Future<void> _handleIncomingLinks() async {
    // If app opened from terminated state
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _consumeSupabaseLink(initialUri);
    }

    // If app is already running
    _linkSub = _appLinks.uriLinkStream.listen((uri) async {
      await _consumeSupabaseLink(uri);
    });
  }

  Future<void> _consumeSupabaseLink(Uri uri) async {
    try {
      // ✅ This makes Supabase set the recovery session from the redirect URL
      await Supabase.instance.client.auth.getSessionFromUrl(uri);

      // Now navigate to reset page
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
      );
    } catch (e) {
      debugPrint("Deep link consume error: $e");
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'EbuCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
