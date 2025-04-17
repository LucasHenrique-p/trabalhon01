import 'package:flutter/material.dart';
import 'package:trabalhon01/controladora.dart' as controladora;
import 'package:trabalhon01/tela_shared.dart' as controladora;

class TelaCadastroProduto extends StatefulWidget {
  const TelaCadastroProduto({super.key});

  @override
  State<TelaCadastroProduto> createState() => _TelaCadastroProdutoState();
}

class _TelaCadastroProdutoState extends State<TelaCadastroProduto> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController unidadeController = TextEditingController();
  final TextEditingController estoqueController = TextEditingController();
  final TextEditingController precoVendaController = TextEditingController();
  final TextEditingController custoController = TextEditingController();
  final TextEditingController codigoBarraController = TextEditingController();
  final controladora.ProdutoControl produtoController =
      controladora.ProdutoControl();
  List<controladora.Produto> produtos = [];
  int status = 0;
  int? produtoEdicaoId;
  bool mostrarCamposCadastro = false;
  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    await produtoController.carregarProdutos();
    setState(() {
      produtos = produtoController.produtos;
    });
  }

  void salvar() async {
    if (nomeController.text.isEmpty ||
        unidadeController.text.isEmpty ||
        estoqueController.text.isEmpty ||
        precoVendaController.text.isEmpty) {
      return;
    }

    if (produtoEdicaoId == null) {
      produtoController.adicionarProduto(
        nomeController.text,
        unidadeController.text,
        int.parse(estoqueController.text),
        double.parse(precoVendaController.text),
        status,
        double.parse(custoController.text),
        codigoBarraController.text,
      );
    } else {
      produtoController.editarProduto(
        produtoEdicaoId!,
        nomeController.text,
        unidadeController.text,
        int.parse(estoqueController.text),
        double.parse(precoVendaController.text),
        status,
        double.parse(custoController.text),
        codigoBarraController.text,
      );
    }

    await produtoController.salvarProdutos();

    nomeController.clear();
    unidadeController.clear();
    estoqueController.clear();
    precoVendaController.clear();
    custoController.clear();
    codigoBarraController.clear();
    produtoEdicaoId = null;

    carregar();
    setState(() {
      mostrarCamposCadastro = false;
    });
  }

  void deletar(int id) async {
    produtoController.removerProduto(id);
    await produtoController.salvarProdutos();
    carregar();
  }

  void editarProduto(controladora.Produto produto) {
    setState(() {
      produtoEdicaoId = produto.id;
      nomeController.text = produto.nome;
      unidadeController.text = produto.unidade;
      estoqueController.text = produto.estoque.toString();
      precoVendaController.text = produto.precoVenda.toString();
      custoController.text = produto.custo.toString();
      codigoBarraController.text = produto.codigoBarra;
      status = produto.status;
      mostrarCamposCadastro = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Produtos')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (mostrarCamposCadastro) ...[
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: unidadeController,
                decoration: const InputDecoration(labelText: 'Unidade'),
              ),
              TextField(
                controller: estoqueController,
                decoration: const InputDecoration(labelText: 'Qtd. Estoque'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: precoVendaController,
                decoration: const InputDecoration(labelText: 'Preço de Venda'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: custoController,
                decoration: const InputDecoration(labelText: 'Custo'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: codigoBarraController,
                decoration: const InputDecoration(labelText: 'Código de Barra'),
              ),
              Row(
                children: [
                  const Text('Status: '),
                  Radio<int>(
                    value: 0,
                    groupValue: status,
                    onChanged: (int? value) {
                      setState(() {
                        status = value!;
                      });
                    },
                  ),
                  const Text('Ativo'),
                  Radio<int>(
                    value: 1,
                    groupValue: status,
                    onChanged: (int? value) {
                      setState(() {
                        status = value!;
                      });
                    },
                  ),
                  const Text('Inativo'),
                ],
              ),
            ],
            ElevatedButton(
              onPressed: salvar,
              child: Text(
                produtoEdicaoId == null
                    ? 'Cadastrar Produto'
                    : 'Salvar Alterações',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: produtos.length,
                itemBuilder: (context, index) {
                  final produto = produtos[index];
                  return ListTile(
                    title: Text(produto.nome),
                    subtitle: Text(
                      'Preço: R\$${produto.precoVenda} | Estoque: ${produto.estoque}',
                    ),
                    onTap: () => editarProduto(produto),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deletar(produto.id),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  produtoEdicaoId = null;
                  nomeController.clear();
                  unidadeController.clear();
                  estoqueController.clear();
                  precoVendaController.clear();
                  custoController.clear();
                  codigoBarraController.clear();
                  status = 0;
                  mostrarCamposCadastro = true;
                });
              },
              child: const Text('Cadastrar Novo Produto'),
            ),
          ],
        ),
      ),
    );
  }
}
