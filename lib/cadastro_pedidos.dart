import 'package:flutter/material.dart';
import 'package:trabalhon01/controladora.dart' as controladora;
import 'tela_shared.dart';

class CadastroPedidos extends StatefulWidget {
  const CadastroPedidos({super.key});

  @override
  State<CadastroPedidos> createState() => _CadastroPedidosState();
}

class _CadastroPedidosState extends State<CadastroPedidos> {
  final TextEditingController idClienteController = TextEditingController();
  final TextEditingController idUsuarioController = TextEditingController();
  final TextEditingController totalPedidoController = TextEditingController();
  final PedidoController pedidoController = PedidoController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<controladora.Pedidos> pedidos = [];
  bool _mostrarFormularioCadastro = false;
  bool _carregando = false;
  controladora.Pedidos? pedidoEditando;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    setState(() => _carregando = true);

    try {
      await pedidoController.carregarPedidos();
      setState(() {
        pedidos = pedidoController.pedidos;
      });
    } catch (e) {
      _mostrarSnackBar('Erro ao carregar pedidos: $e', isError: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _salvarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      if (pedidoEditando != null) {
        await pedidoController.atualizarPedido(
          pedidoEditando!.id,
          int.parse(idClienteController.text.trim()),
          int.parse(idUsuarioController.text.trim()),
          double.parse(totalPedidoController.text.trim()),
          DateTime.now(),
        );
        _mostrarSnackBar('Pedido atualizado com sucesso!');
      } else {
        await pedidoController.adicionarPedido(
          int.parse(idClienteController.text.trim()),
          int.parse(idUsuarioController.text.trim()),
          double.parse(totalPedidoController.text.trim()),
          DateTime.now(),
        );
        _mostrarSnackBar('Pedido cadastrado com sucesso!');
      }

      _limparFormulario();
      await _carregarPedidos();
    } catch (e) {
      _mostrarSnackBar('Erro ao salvar pedido: $e', isError: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _deletarPedido(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmação'),
            content: const Text('Deseja realmente excluir este pedido?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      setState(() => _carregando = true);

      try {
        await pedidoController.removerPedido(id);
        _mostrarSnackBar('Pedido excluído com sucesso!');
        await _carregarPedidos();
      } catch (e) {
        _mostrarSnackBar('Erro ao excluir pedido: $e', isError: true);
      } finally {
        setState(() => _carregando = false);
      }
    }
  }

  void _editarPedido(controladora.Pedidos pedido) {
    setState(() {
      pedidoEditando = pedido;
      idClienteController.text = pedido.idCliente.toString();
      idUsuarioController.text = pedido.idUsuario.toString();
      totalPedidoController.text = pedido.totalPedido.toString();
      _mostrarFormularioCadastro = true;
    });
  }

  void _limparFormulario() {
    idClienteController.clear();
    idUsuarioController.clear();
    totalPedidoController.clear();

    setState(() {
      pedidoEditando = null;
      _mostrarFormularioCadastro = false;
    });
  }

  void _mostrarSnackBar(String mensagem, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String? _validarCampoObrigatorio(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return '$campo é obrigatório';
    }
    return null;
  }

  String? _validarNumero(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return '$campo é obrigatório';
    }
    if (int.tryParse(value.trim()) == null) {
      return '$campo deve ser um número válido';
    }
    return null;
  }

  String? _validarValor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Total é obrigatório';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Total deve ser um valor válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Pedidos'), elevation: 0),
      body:
          _carregando
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_mostrarFormularioCadastro) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _mostrarFormularioCadastro = true;
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Cadastrar Novo Pedido'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildListaPedidos(),
                    ],
                    if (_mostrarFormularioCadastro) ...[
                      _buildFormularioCadastro(),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildListaPedidos() {
    if (pedidos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhum pedido cadastrado',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pedidos.length,
      itemBuilder: (context, index) {
        final pedido = pedidos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(pedido.id.toString())),
            title: Text('Pedido #${pedido.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cliente ID: ${pedido.idCliente}'),
                Text('Usuário ID: ${pedido.idUsuario}'),
                Text('Total: R\$ ${pedido.totalPedido.toStringAsFixed(2)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editarPedido(pedido),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletarPedido(pedido.id),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildFormularioCadastro() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                pedidoEditando != null ? 'Editar Pedido' : 'Novo Pedido',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // ID Cliente
              TextFormField(
                controller: idClienteController,
                decoration: const InputDecoration(
                  labelText: 'ID do Cliente *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validarNumero(value, 'ID do Cliente'),
              ),
              const SizedBox(height: 16),

              // ID Usuário
              TextFormField(
                controller: idUsuarioController,
                decoration: const InputDecoration(
                  labelText: 'ID do Usuário *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validarNumero(value, 'ID do Usuário'),
              ),
              const SizedBox(height: 16),

              // Total do Pedido
              TextFormField(
                controller: totalPedidoController,
                decoration: const InputDecoration(
                  labelText: 'Total do Pedido (R\$) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validarValor,
              ),
              const SizedBox(height: 20),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _carregando ? null : _salvarPedido,
                      icon: const Icon(Icons.save),
                      label: Text(
                        pedidoEditando != null ? 'Atualizar' : 'Salvar',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _carregando ? null : _limparFormulario,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
