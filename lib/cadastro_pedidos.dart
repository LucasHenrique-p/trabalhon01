import 'package:flutter/material.dart';
import 'package:trabalhon01/controladora.dart' as controladora;
import 'package:trabalhon01/tela_shared.dart' as controladora;

class CadastroPedidos extends StatefulWidget {
  const CadastroPedidos({super.key});

  @override
  State<CadastroPedidos> createState() => _CadastroPedidosState();
}

class _CadastroPedidosState extends State<CadastroPedidos> {
  final TextEditingController idPedidoController = TextEditingController();
  final TextEditingController idClienteController = TextEditingController();
  final TextEditingController idUsuarioController = TextEditingController();
  final TextEditingController totalPedidoController = TextEditingController();
  final controladora.PedidoManager pedidoController =
      controladora.PedidoManager();
  List<controladora.Pedidos> pedidos = [];
  bool _mostrarFormularioCadastro = false;
  controladora.Pedidos? pedidoEditando;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    await pedidoController.carregarPedidos();
    setState(() {
      pedidos = pedidoController.pedidos;
    });
  }

  void salvar() async {
    if (idPedidoController.text.isEmpty ||
        idClienteController.text.isEmpty ||
        idUsuarioController.text.isEmpty ||
        totalPedidoController.text.isEmpty)
      return;

    if (pedidoEditando != null) {
      pedidoController.atualizarPedido(
        pedidoEditando!.id,
        int.parse(idClienteController.text),
        int.parse(idUsuarioController.text),
        double.parse(totalPedidoController.text),
        DateTime.now(),
      );
    } else {
      pedidoController.adicionarPedido(
        int.parse(idPedidoController.text),
        int.parse(idClienteController.text),
        int.parse(idUsuarioController.text),
        double.parse(totalPedidoController.text),
        DateTime.now(),
      );
    }

    await pedidoController.salvarPedidos();

    idPedidoController.clear();
    idClienteController.clear();
    idUsuarioController.clear();
    totalPedidoController.clear();

    setState(() {
      pedidoEditando = null;
      _mostrarFormularioCadastro = false;
    });

    carregar();
  }

  void deletar(int id) async {
    pedidoController.removerPedido(id);
    await pedidoController.salvarPedidos();
    carregar();
  }

  void editarPedido(controladora.Pedidos pedido) {
    setState(() {
      pedidoEditando = pedido;
      idPedidoController.text = pedido.id.toString();
      idClienteController.text = pedido.idCliente.toString();
      idUsuarioController.text = pedido.idUsuario.toString();
      totalPedidoController.text = pedido.totalPedido.toString();
      _mostrarFormularioCadastro = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Pedidos')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_mostrarFormularioCadastro) ...[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _mostrarFormularioCadastro = true;
                    idPedidoController.clear();
                    idClienteController.clear();
                    idUsuarioController.clear();
                    totalPedidoController.clear();
                    pedidoEditando = null;
                  });
                },
                child: const Text('Cadastrar Novo Pedido'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    return ListTile(
                      title: Text('Pedido ID: ${pedido.id}'),
                      subtitle: Text(
                        'Cliente ID: ${pedido.idCliente}, Usuário ID: ${pedido.idUsuario}, Total: ${pedido.totalPedido}',
                      ),
                      onTap: () => editarPedido(pedido),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deletar(pedido.id),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_mostrarFormularioCadastro) ...[
              TextField(
                controller: idPedidoController,
                decoration: const InputDecoration(labelText: 'ID do Pedido'),
                keyboardType: TextInputType.number,
                enabled: pedidoEditando == null,
              ),
              TextField(
                controller: idClienteController,
                decoration: const InputDecoration(labelText: 'ID do Cliente'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: idUsuarioController,
                decoration: const InputDecoration(labelText: 'ID do Usuário'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: totalPedidoController,
                decoration: const InputDecoration(labelText: 'Total do Pedido'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: salvar,
                    child: const Text('Salvar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _mostrarFormularioCadastro = false;
                        idPedidoController.clear();
                        idClienteController.clear();
                        idUsuarioController.clear();
                        totalPedidoController.clear();
                        pedidoEditando = null;
                      });
                    },
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
