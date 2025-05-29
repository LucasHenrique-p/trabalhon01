import 'package:flutter/material.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({super.key});

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  final TextEditingController _serverLinkController = TextEditingController();

  void _connectToServer() {
    final serverLink = _serverLinkController.text;
    if (serverLink.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tentando conectar a: $serverLink')),
      );
      // Lógica para conectar ao link
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o link do servidor.')),
      );
    }
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
