import 'package:flutter/material.dart';

class Sincronia extends StatefulWidget {
  const Sincronia({super.key});

  @override
  State<Sincronia> createState() => _SincroniaState();
}

class _SincroniaState extends State<Sincronia> {
  void _buscarDados() {
    // Lógica para buscar dados
  }

  void _enviarRegistros() {
    // Lógica para enviar dados
  }

  void _excluirRegistros() {
    // Lógica para excluir dados
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronia de Dados')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _buscarDados,
              child: const Text('Buscar Dados (GET)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enviarRegistros,
              child: const Text('Enviar Registros (POST)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _excluirRegistros,
              child: const Text('Excluir Registros (DELETE)'),
            ),
          ],
        ),
      ),
    );
  }
}
