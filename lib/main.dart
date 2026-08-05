import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Eslatma: Firebase push xabarnomalarini yoqish uchun
  // `flutterfire configure` orqali firebase_options.dart generatsiya qiling,
  // so'ng quyidagi qatorni oching:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: UzumTezkorApp()));
}
