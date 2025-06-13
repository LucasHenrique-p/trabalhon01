import 'package:flutter/material.dart';
import 'package:trabalhon01/controladora.dart';

class TelaCadastroCliente extends StatefulWidget {
  const TelaCadastroCliente({super.key});

  @override
  State<TelaCadastroCliente> createState() => _TelaCadastroClienteState();
}

class _TelaCadastroClienteState extends State<TelaCadastroCliente> {
  final ClienteController clienteController = ClienteController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController documentoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController ufController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Cliente> clientes = [];
  bool _mostrarFormularioCadastro = false;
  bool _carregando = false;
  bool _carregandoCep = false;
  Cliente? clienteEditando;
  String tipoSelecionado = 'F'; // F = Física, J = Jurídica

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    setState(() => _carregando = true);

    try {
      await clienteController.carregarClientes();
      setState(() {
        clientes = clienteController.clientes;
      });
    } catch (e) {
      _mostrarSnackBar('Erro ao carregar clientes: $e', isError: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _buscarCep() async {
    final cep = cepController.text.trim();
    if (cep.isEmpty) {
      _mostrarSnackBar('Digite um CEP para pesquisar', isError: true);
      return;
    }

    setState(() => _carregandoCep = true);

    try {
      final dadosCep = await ViaCepService.buscarCep(cep);

      if (dadosCep != null) {
        setState(() {
          enderecoController.text = dadosCep['logradouro'] ?? '';
          bairroController.text = dadosCep['bairro'] ?? '';
          cidadeController.text = dadosCep['localidade'] ?? '';
          ufController.text = dadosCep['uf'] ?? '';
          cepController.text = dadosCep['cep'] ?? cep;
        });

        _mostrarSnackBar('Endereço encontrado e preenchido automaticamente!');
      }
    } catch (e) {
      _mostrarSnackBar('Erro ao buscar CEP: $e', isError: true);
    } finally {
      setState(() => _carregandoCep = false);
    }
  }

  Future<void> _salvarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      if (clienteEditando != null) {
        await clienteController.atualizarCliente(
          clienteEditando!.id,
          nomeController.text.trim(),
          tipoSelecionado,
          documentoController.text.trim(),
          emailController.text.trim(),
          telefoneController.text.trim(),
          cepController.text.trim(),
          enderecoController.text.trim(),
          bairroController.text.trim(),
          cidadeController.text.trim(),
          ufController.text.trim().toUpperCase(),
        );
        _mostrarSnackBar('Cliente atualizado com sucesso!');
      } else {
        await clienteController.adicionarCliente(
          nomeController.text.trim(),
          tipoSelecionado,
          documentoController.text.trim(),
          emailController.text.trim(),
          telefoneController.text.trim(),
          cepController.text.trim(),
          enderecoController.text.trim(),
          bairroController.text.trim(),
          cidadeController.text.trim(),
          ufController.text.trim().toUpperCase(),
        );
        _mostrarSnackBar('Cliente cadastrado com sucesso!');
      }

      _limparFormulario();
      await _carregarClientes();
    } catch (e) {
      _mostrarSnackBar('Erro ao salvar cliente: $e', isError: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _deletarCliente(int id, String nome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmação'),
            content: Text('Deseja realmente excluir o cliente "$nome"?'),
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
        await clienteController.removerCliente(id);
        _mostrarSnackBar('Cliente excluído com sucesso!');
        await _carregarClientes();
      } catch (e) {
        _mostrarSnackBar('Erro ao excluir cliente: $e', isError: true);
      } finally {
        setState(() => _carregando = false);
      }
    }
  }

  void _editarCliente(Cliente cliente) {
    setState(() {
      clienteEditando = cliente;
      nomeController.text = cliente.nome;
      tipoSelecionado = cliente.tipo;
      documentoController.text = cliente.cpfCnpj;
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

  void _limparFormulario() {
    nomeController.clear();
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
      tipoSelecionado = 'F';
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

  String? _validarDocumento(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CPF/CNPJ é obrigatório';
    }
    final doc = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (tipoSelecionado == 'F' && doc.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    if (tipoSelecionado == 'J' && doc.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value != null && value.isNotEmpty && !value.contains('@')) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validarCep(String? value) {
    if (value != null && value.isNotEmpty) {
      final cep = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (cep.length != 8) {
        return 'CEP deve ter 8 dígitos';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Clientes'), elevation: 0),
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
                        label: const Text('Cadastrar Novo Cliente'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildListaClientes(),
                    ],
                    if (_mostrarFormularioCadastro) ...[
                      _buildFormularioCadastro(),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildListaClientes() {
    if (clientes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhum cliente cadastrado',
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
      itemCount: clientes.length,
      itemBuilder: (context, index) {
        final cliente = clientes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(cliente.nome[0].toUpperCase())),
            title: Text(cliente.nome),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${cliente.id}'),
                Text(cliente.tipo == 'F' ? 'Pessoa Física' : 'Pessoa Jurídica'),
                Text('Doc: ${cliente.cpfCnpj}'),
                if (cliente.email.isNotEmpty) Text('Email: ${cliente.email}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editarCliente(cliente),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletarCliente(cliente.id, cliente.nome),
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
                clienteEditando != null ? 'Editar Cliente' : 'Novo Cliente',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // Nome
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: _validarNome,
              ),
              const SizedBox(height: 16),

              // Tipo
              DropdownButtonFormField<String>(
                value: tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: const [
                  DropdownMenuItem(value: 'F', child: Text('Pessoa Física')),
                  DropdownMenuItem(value: 'J', child: Text('Pessoa Jurídica')),
                ],
                onChanged: (value) {
                  setState(() {
                    tipoSelecionado = value!;
                    documentoController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),

              // CPF/CNPJ
              TextFormField(
                controller: documentoController,
                decoration: InputDecoration(
                  labelText: '${tipoSelecionado == 'F' ? 'CPF' : 'CNPJ'} *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                validator: _validarDocumento,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validarEmail,
              ),
              const SizedBox(height: 16),

              // Telefone
              TextFormField(
                controller: telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // CEP com botão de pesquisa
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: cepController,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                        hintText: '00000-000',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validarCep,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: _carregandoCep ? null : _buscarCep,
                      icon:
                          _carregandoCep
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.search),
                      label: const Text('Buscar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Endereço
              TextFormField(
                controller: enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 16),

              // Bairro
              TextFormField(
                controller: bairroController,
                decoration: const InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 16),

              // Cidade
              TextFormField(
                controller: cidadeController,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 16),

              // UF
              TextFormField(
                controller: ufController,
                decoration: const InputDecoration(
                  labelText: 'UF',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                maxLength: 2,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 20),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _carregando ? null : _salvarCliente,
                      icon: const Icon(Icons.save),
                      label: Text(
                        clienteEditando != null ? 'Atualizar' : 'Salvar',
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
