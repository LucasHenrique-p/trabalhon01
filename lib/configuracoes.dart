import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Configuracoes extends StatefulWidget {
  const Configuracoes({super.key});

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  final TextEditingController _serverLinkController = TextEditingController();

  Future<void> _connectToServer() async {
    // final serverLink = _serverLinkController.text;
    // if (serverLink.isNotEmpty) {
    //   var response = await http.get(Uri.parse(_serverLinkController.text));
    //   if (response.statusCode >= 200 && response.statusCode <= 299) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('${_serverLinkController.text} conectado.')),
    //     );
    //   }
    // } else {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(const SnackBar(content: Text('Endereço incorreto')));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _serverLinkController,
              decoration: const InputDecoration(
                labelText: 'Link do Servidor',
                hintText: 'Ex: http://seu_servidor.com/api',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connectToServer,
              child: const Text('Conectar'),
            ),
          ],
        ),
      ),
    );
  }
}
