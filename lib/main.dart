import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:herkes_icin_sanat/pages/HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MaterialColor kDark = const MaterialColor(
    0xFF121212,
    const <int, Color>{
      50: const Color(0xFF121212),
      100: const Color(0xFF121212),
      200: const Color(0xFF121212),
      300: const Color(0xFF121212),
      400: const Color(0xFF121212),
      500: const Color(0xFF121212),
      600: const Color(0xFF121212),
      700: const Color(0xFF121212),
      800: const Color(0xFF121212),
      900: const Color(0xFF121212),
    },
  );
  final MaterialColor kOrange = const MaterialColor(
    0xFFFFC68A,
    const <int, Color>{
      50: const Color(0xFFFFC68A),
      100: const Color(0xFFFFC68A),
      200: const Color(0xFFFFC68A),
      300: const Color(0xFFFFC68A),
      400: const Color(0xFFFFC68A),
      500: const Color(0xFFFFC68A),
      600: const Color(0xFFFFC68A),
      700: const Color(0xFFFFC68A),
      800: const Color(0xFFFFC68A),
      900: const Color(0xFFFFC68A),
    },
  );

  final MaterialColor kKahve = const MaterialColor(
    0xFF2D2D2D,
    const <int, Color>{
      50: const Color(0xFF2D2D2D),
      100: const Color(0xFF2D2D2D),
      200: const Color(0xFF2D2D2D),
      300: const Color(0xFF2D2D2D),
      400: const Color(0xFF2D2D2D),
      500: const Color(0xFF2D2D2D),
      600: const Color(0xFF2D2D2D),
      700: const Color(0xFF2D2D2D),
      800: const Color(0xFF2D2D2D),
      900: const Color(0xFF2D2D2D),
    },
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kDark,
        dialogBackgroundColor: Colors.black,
        primarySwatch: kOrange,
        accentColor: kKahve,
        cardColor: Colors.white70,
        canvasColor: kKahve,
      ),
      home: HomePage(),
    );
  }
}
