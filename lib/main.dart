import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'services/navigation_service.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Đua Ông Táo',
      theme: ThemeData(
        fontFamily: 'FzCoTrang',
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: const Color(
            0xff0BA6DF,
          ).withAlpha((0.2 * 255).toInt()),
          cursorColor: const Color(0xff0BA6DF),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
