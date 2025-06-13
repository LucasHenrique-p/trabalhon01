import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trabalhon01/controladora.dart';

class Sincronia extends StatefulWidget {
  const Sincronia({super.key});

  @override
  State<Sincronia> createState() => _SincroniaState();
}

class _SincroniaState extends State<Sincronia> {
  List<Usuario> listaUsuarios = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> _buscarDados() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      listaUsuarios.clear();
    });

    try {
      var url = "http://192.168.56.1:8080/usuarios";
      var response = await http.get(Uri.parse(url));

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        var jsonStr = response.body;
        var json = jsonDecode(jsonStr);

        if (json is Map<String, dynamic> && json.containsKey('dados')) {
          List<dynamic> dados = json['dados'];
          setState(() {
            listaUsuarios.addAll(
              dados.map((e) => Usuario.fromJson(e)).toList(),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Usuários não encontrados';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Falha ao buscar dados: Status ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao conectar ou processar dados: $e';
        isLoading = false;
      });
    }
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
              onPressed: isLoading ? null : _buscarDados,
              child: const Text('Buscar Dados (GET)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enviarRegistros,
              child: const Text('Enviar Registros (POST)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _excluirRegistros,
              child: const Text('Excluir Registros (DELETE)'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            // Exibição dos dados buscados
            Expanded(
              child:
                  listaUsuarios.isEmpty && !isLoading && errorMessage == null
                      ? const Center(
                        child: Text(
                          'Nenhum dado para exibir. Clique em "Buscar Dados".',
                        ),
                      )
                      : ListView.builder(
                        itemCount: listaUsuarios.length,
                        itemBuilder: (context, index) {
                          final usuario = listaUsuarios[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(usuario.id.toString()),
                              ),
                              title: Text(usuario.nome),
                              subtitle: Text('${usuario.id}'),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
