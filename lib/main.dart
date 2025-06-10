// main.dart
import 'package:flutter/material.dart';
import 'package:trabalhon01/banco.dart';
import 'tela_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BancoHelper().initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App CRUD Básico',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaLogin(),
    );
  }
}
