import 'package:flutter/material.dart';
import 'package:trabalhon01/cadastro_cliente.dart';
import 'package:trabalhon01/cadastro_pedidos.dart';
import 'package:trabalhon01/cadastro_produto.dart';
import 'package:trabalhon01/cadastro_usuario.dart';
import 'package:trabalhon01/configuracoes.dart';
import 'package:trabalhon01/sincronia.dart';

class TelaBase extends StatefulWidget {
  const TelaBase({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TelaBaseState createState() => _TelaBaseState();
}

class _TelaBaseState extends State<TelaBase> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const TelaCadastroUsuario(),
    const TelaCadastroCliente(),
    const TelaCadastroProduto(),
    const CadastroPedidos(),
    const Sincronia(),
    const Configuracoes(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela Principal')),
      body: _pages[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_2),
              title: const Text('Usuários'),
              onTap: () {
                _onItemTapped(0);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Clientes'),
              onTap: () {
                _onItemTapped(1);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Produtos'),
              onTap: () {
                _onItemTapped(2);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.request_page),
              title: const Text('Pedidos'),
              onTap: () {
                _onItemTapped(3);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sincronia de Dados'),
              onTap: () {
                _onItemTapped(4);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                _onItemTapped(5);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
