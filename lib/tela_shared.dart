import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trabalhon01/controladora.dart';

class ClienteControl {
  List<Cliente> clientes = [];

  Future<void> carregarClientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dados = prefs.getString('clientes');
    if (dados != null) {
      List lista = json.decode(dados);
      clientes = lista.map((e) => Cliente.fromJson(e)).toList();
    }
  }

  Future<void> salvarClientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dados = json.encode(clientes.map((e) => e.toJson()).toList());
    await prefs.setString('clientes', dados);
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

  void adicionarCliente(
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
    int id = clientes.isEmpty ? 1 : clientes.last.id + 1;
    Cliente novoCliente = Cliente(
      id: id,
      nome: nome,
      tipo: tipo,
      documento: documento,
      email: email,
      telefone: telefone,
      cep: cep,
      endereco: endereco,
      bairro: bairro,
      cidade: cidade,
      uf: uf,
    );
    clientes.add(novoCliente);
  }

  void removerCliente(int id) {
    clientes.removeWhere((c) => c.id == id);
  }
}

class UsuarioManager {
  List<Usuario> usuarios = [];

  Future<void> carregarUsuarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dados = prefs.getString('usuarios');
    if (dados != null) {
      List lista = json.decode(dados);
      usuarios = lista.map((e) => Usuario.fromJson(e)).toList();
    }
  }

  Future<void> salvarUsuarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dados = json.encode(usuarios.map((e) => e.toJson()).toList());
    await prefs.setString('usuarios', dados);
  }

  void adicionarUsuario(String nome, String senha) {
    int id = usuarios.isEmpty ? 1 : usuarios.last.id + 1;
    Usuario novoUsuario = Usuario(id: id, nome: nome, senha: senha);
    usuarios.add(novoUsuario);
  }

  void atualizarUsuario(int id, String nome, String senha) {
    final usuario = usuarios.firstWhere((u) => u.id == id);
    usuario.nome = nome;
    usuario.senha = senha;
  }

  void removerUsuario(int id) {
    usuarios.removeWhere((u) => u.id == id);
  }
}

class UsuarioController {
  List<Usuario> usuarios = [];

  Future<void> carregarUsuarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dados = prefs.getString('usuarios');

    if (dados != null) {
      List lista = json.decode(dados);
      usuarios = lista.map((e) => Usuario.fromJson(e)).toList();
    }

    if (!usuarios.any((usuario) => usuario.nome == 'admin')) {
      adicionarUsuario('admin', 'admin');
      await salvarUsuarios();
    }
  }

  Future<void> salvarUsuarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dados = json.encode(usuarios.map((e) => e.toJson()).toList());
    await prefs.setString('usuarios', dados);
  }

  void adicionarUsuario(String nome, String senha) {
    int id = usuarios.isEmpty ? 1 : usuarios.last.id + 1;
    Usuario novoUsuario = Usuario(id: id, nome: nome, senha: senha);
    usuarios.add(novoUsuario);
  }

  void removerUsuario(int id) {
    usuarios.removeWhere((u) => u.id == id);
  }

  bool login(String nome, String senha) {
    final Usuario? usuario = usuarios.cast<Usuario?>().firstWhere(
      (u) => u?.nome == nome && u?.senha == senha,
      orElse: () => null,
    );
    return usuario != null;
  }
}

class ProdutoControl {
  List<Produto> produtos = [];

  Future<void> carregarProdutos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dados = prefs.getString('produtos');
    if (dados != null) {
      List lista = json.decode(dados);
      produtos = lista.map((e) => Produto.fromJson(e)).toList();
    }
  }

  Future<void> salvarProdutos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dados = json.encode(produtos.map((e) => e.toJson()).toList());
    await prefs.setString('produtos', dados);
  }

  void editarProduto(
    int id,
    String nome,
    String unidade,
    int estoque,
    double precoVenda,
    int status,
    double custo,
    String codigoBarra,
  ) {
    Produto produto = produtos.firstWhere((produto) => produto.id == id);

    produto.nome = nome;
    produto.unidade = unidade;
    produto.estoque = estoque;
    produto.precoVenda = precoVenda;
    produto.status = status;
    produto.custo = custo;
    produto.codigoBarra = codigoBarra;
  }

  void adicionarProduto(
    String nome,
    String unidade,
    int estoque,
    double precoVenda,
    int status,
    double custo,
    String codigoBarra,
  ) {
    int id = produtos.isEmpty ? 1 : produtos.last.id + 1;
    Produto novoProduto = Produto(
      id: id,
      nome: nome,
      unidade: unidade,
      estoque: estoque,
      precoVenda: precoVenda,
      status: status,
      custo: custo,
      codigoBarra: codigoBarra,
    );
    produtos.add(novoProduto);
  }

  void removerProduto(int id) {
    produtos.removeWhere((p) => p.id == id);
  }
}
