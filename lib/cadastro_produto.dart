import 'package:flutter/material.dart';
import 'package:trabalhon01/controladora.dart';
import 'package:trabalhon01/tela_shared.dart';

class TelaCadastroProduto extends StatefulWidget {
  const TelaCadastroProduto({super.key});

  @override
  State<TelaCadastroProduto> createState() => _TelaCadastroProdutoState();
}

class _TelaCadastroProdutoState extends State<TelaCadastroProduto> {
  final ProdutoController produtoController = ProdutoController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController qtdEstoqueController = TextEditingController();
  final TextEditingController precoVendaController = TextEditingController();
  final TextEditingController custoController = TextEditingController();
  final TextEditingController codigoBarraController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Produto> produtos = [];
  bool _mostrarFormularioCadastro = false;
  bool _carregando = false;
  Produto? produtoEditando;
  String unidadeSelecionada =
      'un'; // Valores válidos: 'un', 'cx', 'kg', 'lt', 'ml'
  int statusSelecionado = 0;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() => _carregando = true);

    try {
      await produtoController.carregarProdutos();
      setState(() {
        produtos = produtoController.produtos;
      });
    } catch (e) {
      _mostrarSnackBar('Erro ao carregar produtos: $e', isError: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _salvarProduto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      if (produtoEditando != null) {
        await produtoController.editarProduto(
          produtoEditando!.id,
          nomeController.text.trim(),
          unidadeSelecionada,
          double.parse(
            qtdEstoqueController.text.isEmpty ? '0' : qtdEstoqueController.text,
          ),
          double.parse(precoVendaController.text),
          statusSelecionado,
          double.parse(
            custoController.text.isEmpty ? '0' : custoController.text,
          ),
          codigoBarraController.text.trim(),
        );
        _mostrarSnackBar('Produto atualizado com sucesso!');
      } else {
        await produtoController.adicionarProduto(
          nomeController.text.trim(),
          unidadeSelecionada,
          double.parse(
            qtdEstoqueController.text.isEmpty ? '0' : qtdEstoqueController.text,
          ),
          double.parse(precoVendaController.text),
          statusSelecionado,
          double.parse(
            custoController.text.isEmpty ? '0' : custoController.text,
          ),
          codigoBarraController.text.trim(),
        );
        _mostrarSnackBar('Produto cadastrado com sucesso!');
      }

      _limparFormulario();
      await _carregarProdutos();
    } catch (e) {
      _mostrarSnackBar('Erro ao salvar produto: $e', isError: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _deletarProduto(int id, String nome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmação'),
            content: Text('Deseja realmente excluir o produto "$nome"?'),
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
        await produtoController.removerProduto(id);
        _mostrarSnackBar('Produto excluído com sucesso!');
        await _carregarProdutos();
      } catch (e) {
        _mostrarSnackBar('Erro ao excluir produto: $e', isError: true);
      } finally {
        setState(() => _carregando = false);
      }
    }
  }

  void _editarProduto(Produto produto) {
    setState(() {
      produtoEditando = produto;
      nomeController.text = produto.nome;
      unidadeSelecionada = produto.unidade;
      qtdEstoqueController.text = produto.estoque.toString();
      precoVendaController.text = produto.precoVenda.toString();
      statusSelecionado = produto.status;
      custoController.text = produto.custo?.toString() ?? '';
      codigoBarraController.text = produto.codigoBarra ?? '';
      _mostrarFormularioCadastro = true;
    });
  }

  void _limparFormulario() {
    nomeController.clear();
    qtdEstoqueController.clear();
    precoVendaController.clear();
    custoController.clear();
    codigoBarraController.clear();

    setState(() {
      produtoEditando = null;
      unidadeSelecionada = 'un';
      statusSelecionado = 0;
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

  String? _validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validarPrecoVenda(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Preço de venda é obrigatório';
    }
    final preco = double.tryParse(value);
    if (preco == null || preco <= 0) {
      return 'Preço deve ser um valor positivo';
    }
    return null;
  }

  String? _validarNumero(String? value, String campo) {
    if (value != null && value.isNotEmpty) {
      final numero = double.tryParse(value);
      if (numero == null || numero < 0) {
        return '$campo deve ser um número válido';
      }
    }
    return null;
  }

  String _getStatusTexto(int status) {
    return status == 0 ? 'Ativo' : 'Inativo';
  }

  String _getUnidadeTexto(String unidade) {
    switch (unidade) {
      case 'un':
        return 'Unidade';
      case 'cx':
        return 'Caixa';
      case 'kg':
        return 'Quilograma';
      case 'lt':
        return 'Litro';
      case 'ml':
        return 'Mililitro';
      default:
        return unidade;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Produtos'), elevation: 0),
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
                        label: const Text('Cadastrar Novo Produto'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildListaProdutos(),
                    ],
                    if (_mostrarFormularioCadastro) ...[
                      _buildFormularioCadastro(),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildListaProdutos() {
    if (produtos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhum produto cadastrado',
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
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        final produto = produtos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: produto.status == 0 ? Colors.green : Colors.red,
              child: Icon(Icons.inventory_2, color: Colors.white),
            ),
            title: Text(produto.nome),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unidade: ${_getUnidadeTexto(produto.unidade)}'),
                Text('Estoque: ${produto.estoque}'),
                Text('Preço: R\$ ${produto.precoVenda.toStringAsFixed(2)}'),
                Text('Status: ${_getStatusTexto(produto.status)}'),
                if (produto.codigoBarra != null &&
                    produto.codigoBarra!.isNotEmpty)
                  Text('Código: ${produto.codigoBarra}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editarProduto(produto),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletarProduto(produto.id, produto.nome),
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
                produtoEditando != null ? 'Editar Produto' : 'Novo Produto',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // Nome
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: _validarNome,
              ),
              const SizedBox(height: 16),

              // Unidade
              DropdownButtonFormField<String>(
                value: unidadeSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Unidade *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
                items: const [
                  DropdownMenuItem(value: 'un', child: Text('Unidade')),
                  DropdownMenuItem(value: 'cx', child: Text('Caixa')),
                  DropdownMenuItem(value: 'kg', child: Text('Quilograma')),
                  DropdownMenuItem(value: 'lt', child: Text('Litro')),
                  DropdownMenuItem(value: 'ml', child: Text('Mililitro')),
                ],
                onChanged: (value) {
                  setState(() {
                    unidadeSelecionada = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Quantidade em Estoque
              TextFormField(
                controller: qtdEstoqueController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade em Estoque',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => _validarNumero(value, 'Quantidade'),
              ),
              const SizedBox(height: 16),

              // Preço de Venda
              TextFormField(
                controller: precoVendaController,
                decoration: const InputDecoration(
                  labelText: 'Preço de Venda (R\$) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validarPrecoVenda,
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<int>(
                value: statusSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Ativo')),
                  DropdownMenuItem(value: 1, child: Text('Inativo')),
                ],
                onChanged: (value) {
                  setState(() {
                    statusSelecionado = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Custo
              TextFormField(
                controller: custoController,
                decoration: const InputDecoration(
                  labelText: 'Custo (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money_off),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => _validarNumero(value, 'Custo'),
              ),
              const SizedBox(height: 16),

              // Código de Barras
              TextFormField(
                controller: codigoBarraController,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _carregando ? null : _salvarProduto,
                      icon: const Icon(Icons.save),
                      label: Text(
                        produtoEditando != null ? 'Atualizar' : 'Salvar',
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
