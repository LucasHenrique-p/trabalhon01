import 'package:flutter/material.dart';
import 'package:trabalhon01/controladora.dart' as controladora;
import 'package:trabalhon01/tela_shared.dart' as controladora;

class TelaCadastroCliente extends StatefulWidget {
  const TelaCadastroCliente({super.key});

  @override
  State<TelaCadastroCliente> createState() => _TelaCadastroClienteState();
}

class _TelaCadastroClienteState extends State<TelaCadastroCliente> {
  final controladora.ClienteControl clienteController =
      controladora.ClienteControl();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController documentoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController ufController = TextEditingController();
  List<controladora.Cliente> clientes = [];
  bool _mostrarFormularioCadastro = false;
  controladora.Cliente? clienteEditando;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void atualizarCliente(
    int id,
    String nome,
    String tipo,
    String documento,
    String email,
    String telefone,
    String cep,
    String endereco,
    String bairro,
    String cidade,
    String uf,
  ) {
    final cliente = clientes.firstWhere((c) => c.id == id);
    cliente.nome = nome;
    cliente.tipo = tipo;
    cliente.documento = documento;
    cliente.email = email;
    cliente.telefone = telefone;
    cliente.cep = cep;
    cliente.endereco = endereco;
    cliente.bairro = bairro;
    cliente.cidade = cidade;
    cliente.uf = uf;
  }

  void carregar() async {
    await clienteController.carregarClientes();
    setState(() {
      clientes = clienteController.clientes;
    });
  }

  void salvar() async {
    if (nomeController.text.isEmpty ||
        tipoController.text.isEmpty ||
        documentoController.text.isEmpty)
      return;

    if (clienteEditando != null) {
      clienteController.atualizarCliente(
        clienteEditando!.id,
        nomeController.text,
        tipoController.text,
        documentoController.text,
        emailController.text,
        telefoneController.text,
        cepController.text,
        enderecoController.text,
        bairroController.text,
        cidadeController.text,
        ufController.text,
      );
    } else {
      clienteController.adicionarCliente(
        nomeController.text,
        tipoController.text,
        documentoController.text,
        emailController.text,
        telefoneController.text,
        cepController.text,
        enderecoController.text,
        bairroController.text,
        cidadeController.text,
        ufController.text,
      );
    }

    await clienteController.salvarClientes();

    nomeController.clear();
    tipoController.clear();
    documentoController.clear();
    emailController.clear();
    telefoneController.clear();
    cepController.clear();
    enderecoController.clear();
    bairroController.clear();
    cidadeController.clear();
    ufController.clear();

    setState(() {
      clienteEditando = null;
      _mostrarFormularioCadastro = false;
    });

    carregar();
  }

  void deletar(int id) async {
    clienteController.removerCliente(id);
    await clienteController.salvarClientes();
    carregar();
  }

  void editarCliente(controladora.Cliente cliente) {
    setState(() {
      clienteEditando = cliente;
      nomeController.text = cliente.nome;
      tipoController.text = cliente.tipo;
      documentoController.text = cliente.documento;
      emailController.text = cliente.email;
      telefoneController.text = cliente.telefone;
      cepController.text = cliente.cep;
      enderecoController.text = cliente.endereco;
      bairroController.text = cliente.bairro;
      cidadeController.text = cliente.cidade;
      ufController.text = cliente.uf;
      _mostrarFormularioCadastro = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Clientes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_mostrarFormularioCadastro) ...[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _mostrarFormularioCadastro = true;
                  });
                },
                child: const Text('Cadastrar Novo Cliente'),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: clientes.length,
                itemBuilder: (context, index) {
                  final cliente = clientes[index];
                  return ListTile(
                    title: Text(cliente.nome),
                    subtitle: Text(cliente.tipo),
                    onTap: () => editarCliente(cliente),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deletar(cliente.id),
                    ),
                  );
                },
              ),
            ],
            if (_mostrarFormularioCadastro) ...[
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: tipoController,
                decoration: const InputDecoration(labelText: 'Tipo (F ou J)'),
              ),
              TextField(
                controller: documentoController,
                decoration: const InputDecoration(labelText: 'CPF/CNPJ'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              TextField(
                controller: telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              TextField(
                controller: cepController,
                decoration: const InputDecoration(labelText: 'CEP'),
              ),
              TextField(
                controller: enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              TextField(
                controller: bairroController,
                decoration: const InputDecoration(labelText: 'Bairro'),
              ),
              TextField(
                controller: cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
              ),
              TextField(
                controller: ufController,
                decoration: const InputDecoration(labelText: 'UF'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: salvar,
                    child: const Text('Salvar'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _mostrarFormularioCadastro = false;
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
