import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NavApp());
}

class NavApp extends StatelessWidget {
  const NavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NAV',

      // 👇 Replace your old Scaffold with this
      home: const HomeScreen(),
    );
  }
}

// 👇 Add this BELOW the NavApp class
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NAV"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final apps = Firebase.apps;

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Firebase"),
                content: Text(
                  "Connected!\nApps: ${apps.length}",
                ),
              ),
            );
          },
          child: const Text("Check Firebase"),
        ),
      ),
    );
  }
}