import 'package:flutter/material.dart';
import 'package:trabalhon01/controladora.dart';

class CadastroPedidos extends StatefulWidget {
  const CadastroPedidos({super.key});

  @override
  State<CadastroPedidos> createState() => _CadastroPedidosState();
}

class _CadastroPedidosState extends State<CadastroPedidos> {
  final TextEditingController idClienteController = TextEditingController();
  final TextEditingController idUsuarioController = TextEditingController();

  final TextEditingController idProdutoController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController precoUnitarioController = TextEditingController();

  final TextEditingController valorPagamentoController =
      TextEditingController();
  final TextEditingController descricaoPagamentoController =
      TextEditingController();

  final PedidoController pedidoController = PedidoController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formItemKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formPagamentoKey = GlobalKey<FormState>();

  List<Pedidos> pedidos = [];
  List<ItemPedido> itensPedido = [];
  List<PagamentoPedido> pagamentosPedido = [];

  bool _mostrarFormularioCadastro = false;
  bool _carregando = false;
  Pedidos? pedidoEditando;

  final List<String> tiposPagamento = [
    'Cartão de Débito',
    'Cartão de Crédito',
    'PIX',
  ];
  String tiposPagamentoSelecionado = 'PIX';

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

    if (itensPedido.isEmpty) {
      _mostrarSnackBar('O pedido deve possuir no mínimo 1 item', isError: true);
      return;
    }

    if (pagamentosPedido.isEmpty) {
      _mostrarSnackBar(
        'O pedido deve possuir no mínimo 1 pagamento',
        isError: true,
      );
      return;
    }

    double totalItens = _calcularTotalItens();
    double totalPagamentos = _calcularTotalPagamentos();

    if ((totalItens - totalPagamentos).abs() > 0.01) {
      _mostrarSnackBar(
        'O total dos pagamentos (R\$ ${totalPagamentos.toStringAsFixed(2)}) deve ser igual ao total dos itens (R\$ ${totalItens.toStringAsFixed(2)})',
        isError: true,
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      if (pedidoEditando != null) {
        await pedidoController.atualizarPedido(
          pedidoEditando!.id,
          int.parse(idClienteController.text.trim()),
          int.parse(idUsuarioController.text.trim()),
          totalItens,
          DateTime.now(),
          itensPedido,
          pagamentosPedido,
        );
        _mostrarSnackBar('Pedido atualizado com sucesso!');
      } else {
        await pedidoController.adicionarPedido(
          int.parse(idClienteController.text.trim()),
          int.parse(idUsuarioController.text.trim()),
          totalItens,
          DateTime.now(),
          itensPedido,
          pagamentosPedido,
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

  Future<void> _editarPedido(Pedidos pedido) async {
    setState(() => _carregando = true);

    try {
      List<ItemPedido> itens = await pedidoController.carregarItensPedido(
        pedido.id,
      );
      List<PagamentoPedido> pagamentos = await pedidoController
          .carregarPagamentosPedido(pedido.id);

      setState(() {
        pedidoEditando = pedido;
        idClienteController.text = pedido.idCliente.toString();
        idUsuarioController.text = pedido.idUsuario.toString();
        itensPedido = itens;
        pagamentosPedido = pagamentos;
        _mostrarFormularioCadastro = true;
      });
    } catch (e) {
      _mostrarSnackBar('Erro ao carregar dados do pedido: $e', isError: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _limparFormulario() {
    idClienteController.clear();
    idUsuarioController.clear();
    itensPedido.clear();
    pagamentosPedido.clear();

    setState(() {
      pedidoEditando = null;
      _mostrarFormularioCadastro = false;
    });
  }

  void _adicionarItem() {
    if (!_formItemKey.currentState!.validate()) return;

    double quantidade = double.parse(quantidadeController.text.trim());
    double precoUnitario = double.parse(precoUnitarioController.text.trim());
    double total = quantidade * precoUnitario;

    setState(() {
      itensPedido.add(
        ItemPedido(
          idPedido: 0,
          idProduto: int.parse(idProdutoController.text.trim()),
          quantidade: quantidade,
          precoUnitario: precoUnitario,
          total: total,
        ),
      );
    });

    _limparFormularioItem();
    Navigator.of(context).pop();
  }

  void _removerItem(int index) {
    setState(() {
      itensPedido.removeAt(index);
    });
  }

  void _adicionarPagamento() {
    if (!_formPagamentoKey.currentState!.validate()) return;

    double valor = double.parse(valorPagamentoController.text.trim());

    setState(() {
      pagamentosPedido.add(
        PagamentoPedido(
          idPedido: 0,
          tipo: tiposPagamentoSelecionado,
          valor: valor,
          descricao: descricaoPagamentoController.text.trim(),
        ),
      );
    });

    _limparFormularioPagamento();
    Navigator.of(context).pop();
  }

  void _removerPagamento(int index) {
    setState(() {
      pagamentosPedido.removeAt(index);
    });
  }

  void _limparFormularioItem() {
    idProdutoController.clear();
    quantidadeController.clear();
    precoUnitarioController.clear();
  }

  void _limparFormularioPagamento() {
    valorPagamentoController.clear();
    descricaoPagamentoController.clear();
    tiposPagamentoSelecionado = 'PIX';
  }

  double _calcularTotalItens() {
    return itensPedido.fold(0.0, (total, item) => total + item.total);
  }

  double _calcularTotalPagamentos() {
    return pagamentosPedido.fold(
      0.0,
      (total, pagamento) => total + pagamento.valor,
    );
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

  String? _validarNumero(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return '$campo é obrigatório';
    }
    if (int.tryParse(value.trim()) == null) {
      return '$campo deve ser um número válido';
    }
    return null;
  }

  String? _validarValor(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return '$campo é obrigatório';
    }
    if (double.tryParse(value.trim()) == null) {
      return '$campo deve ser um valor válido';
    }
    if (double.parse(value.trim()) <= 0) {
      return '$campo deve ser maior que zero';
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
                Text(
                  'Data: ${pedido.dataCriacao.day}/${pedido.dataCriacao.month}/${pedido.dataCriacao.year}',
                ),
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
    double totalItens = _calcularTotalItens();
    double totalPagamentos = _calcularTotalPagamentos();
    bool totaisBalanceados = (totalItens - totalPagamentos).abs() <= 0.01;

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

              // Dados do pedido
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: idClienteController,
                      decoration: const InputDecoration(
                        labelText: 'ID do Cliente *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) => _validarNumero(value, 'ID do Cliente'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: idUsuarioController,
                      decoration: const InputDecoration(
                        labelText: 'ID do Usuário *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) => _validarNumero(value, 'ID do Usuário'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Seção de Itens
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Itens do Pedido',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _mostrarModalItem(),
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (itensPedido.isEmpty)
                        const Text(
                          'Nenhum item adicionado. Adicione pelo menos 1 item.',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: itensPedido.length,
                          itemBuilder: (context, index) {
                            final item = itensPedido[index];
                            return Card(
                              child: ListTile(
                                title: Text('Produto ID: ${item.idProduto}'),
                                subtitle: Text(
                                  'Qtd: ${item.quantidade} × R\$ ${item.precoUnitario.toStringAsFixed(2)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'R\$ ${item.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removerItem(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      if (itensPedido.isNotEmpty) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total dos Itens:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'R\$ ${totalItens.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Seção de Pagamentos
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pagamentos',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _mostrarModalPagamento(),
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Pagamento'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (pagamentosPedido.isEmpty)
                        const Text(
                          'Nenhum pagamento adicionado. Adicione pelo menos 1 pagamento.',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pagamentosPedido.length,
                          itemBuilder: (context, index) {
                            final pagamento = pagamentosPedido[index];
                            return Card(
                              child: ListTile(
                                title: Text(pagamento.tipo),
                                subtitle:
                                    pagamento.descricao.isNotEmpty
                                        ? Text(pagamento.descricao)
                                        : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'R\$ ${pagamento.valor.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removerPagamento(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      if (pagamentosPedido.isNotEmpty) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total dos Pagamentos:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'R\$ ${totalPagamentos.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Validação dos totais
              if (itensPedido.isNotEmpty && pagamentosPedido.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        totaisBalanceados
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: totaisBalanceados ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        totaisBalanceados ? Icons.check_circle : Icons.error,
                        color: totaisBalanceados ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          totaisBalanceados
                              ? 'Totais balanceados corretamente!'
                              : 'ATENÇÃO: Total dos itens (R\$ ${totalItens.toStringAsFixed(2)}) diferente do total dos pagamentos (R\$ ${totalPagamentos.toStringAsFixed(2)})',
                          style: TextStyle(
                            color:
                                totaisBalanceados
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
                        backgroundColor:
                            totaisBalanceados &&
                                    itensPedido.isNotEmpty &&
                                    pagamentosPedido.isNotEmpty
                                ? null
                                : Colors.grey,
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

  void _mostrarModalItem() {
    _limparFormularioItem();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Adicionar Item'),
            content: Form(
              key: _formItemKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: idProdutoController,
                    decoration: const InputDecoration(
                      labelText: 'ID do Produto *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => _validarNumero(value, 'ID do Produto'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: quantidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => _validarValor(value, 'Quantidade'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: precoUnitarioController,
                    decoration: const InputDecoration(
                      labelText: 'Preço Unitário (R\$) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator:
                        (value) => _validarValor(value, 'Preço Unitário'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _adicionarItem,
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  void _mostrarModalPagamento() {
    _limparFormularioPagamento();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateModal) => AlertDialog(
                  title: const Text('Adicionar Pagamento'),
                  content: Form(
                    key: _formPagamentoKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: tiposPagamentoSelecionado,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Pagamento *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.payment),
                          ),
                          items:
                              tiposPagamento.map((tipo) {
                                return DropdownMenuItem(
                                  value: tipo,
                                  child: Text(tipo),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setStateModal(() {
                              tiposPagamentoSelecionado = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: valorPagamentoController,
                          decoration: const InputDecoration(
                            labelText: 'Valor (R\$) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) => _validarValor(value, 'Valor'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descricaoPagamentoController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _adicionarPagamento,
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
          ),
    );
  }
}
