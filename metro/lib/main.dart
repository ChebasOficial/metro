import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teste',
      home: Scaffold(
        appBar: AppBar(title: const Text('Funcionou!')),
        body: const Center(
          child: Text('App OK!', style: TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}
