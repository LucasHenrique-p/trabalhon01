import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trabalhon01/banco.dart';
import 'package:trabalhon01/controladora.dart';

class ClienteController {
  List<Cliente> clientes = [];

  Future<void> carregarClientes() async {
    try {
      var db = await BancoHelper().db;
      var dados = await db.query("Cliente");
      clientes = dados.map((e) => Cliente.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao carregar clientes: $e');
      clientes = [];
    }
  }

  Future<void> atualizarCliente(
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
  ) async {
    try {
      var db = await BancoHelper().db;
      Map<String, dynamic> dadosCliente = {
        'nome': nome,
        'tipo': tipo,
        'cpf_cnpj': documento,
        'email': email,
        'telefone': telefone,
        'cep': cep,
        'endereco': endereco,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
      };
      await db.update(
        'Cliente',
        dadosCliente,
        where: "id = ?",
        whereArgs: [id],
      );
      await carregarClientes();
    } catch (e) {
      print('Erro ao atualizar cliente: $e');
      throw e;
    }
  }

  Future<void> adicionarCliente(
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
  ) async {
    try {
      var db = await BancoHelper().db;
      Map<String, dynamic> dadosCliente = {
        'nome': nome,
        'tipo': tipo,
        'cpf_cnpj': documento,
        'email': email,
        'telefone': telefone,
        'cep': cep,
        'endereco': endereco,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
      };
      await db.insert('Cliente', dadosCliente);
      await carregarClientes();
    } catch (e) {
      print('Erro ao adicionar cliente: $e');
      throw e;
    }
  }

  Future<void> removerCliente(int id) async {
    try {
      var db = await BancoHelper().db;
      await db.delete('Cliente', where: "id = ?", whereArgs: [id]);
      await carregarClientes();
    } catch (e) {
      print('Erro ao remover cliente: $e');
      throw e;
    }
  }
}

class UsuarioController {
  List<Usuario> usuarios = [];

  Future<void> carregarUsuarios() async {
    try {
      var db = await BancoHelper().db;
      var dados = await db.query("Usuario");
      usuarios = dados.map((e) => Usuario.fromJson(e)).toList();

      if (!usuarios.any((usuario) => usuario.nome == 'admin')) {
        await adicionarUsuario('admin', 'admin');
      }
    } catch (e) {
      print('Erro ao carregar usuários: $e');
      usuarios = [];
    }
  }

  Future<void> adicionarUsuario(String nome, String senha) async {
    try {
      var db = await BancoHelper().db;
      Map<String, dynamic> dadosUsuario = {'nome': nome, 'senha': senha};
      await db.insert('Usuario', dadosUsuario);
      await carregarUsuarios();
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      throw e;
    }
  }

  Future<void> atualizarUsuario(int id, String nome, String senha) async {
    try {
      var db = await BancoHelper().db;
      Map<String, dynamic> dadosUsuario = {'nome': nome, 'senha': senha};
      await db.update(
        'Usuario',
        dadosUsuario,
        where: "id = ?",
        whereArgs: [id],
      );
      await carregarUsuarios();
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      throw e;
    }
  }

  Future<void> removerUsuario(int id) async {
    try {
      var db = await BancoHelper().db;
      await db.delete('Usuario', where: "id = ?", whereArgs: [id]);
      await carregarUsuarios();
    } catch (e) {
      print('Erro ao remover usuário: $e');
      throw e;
    }
  }

  bool login(String nome, String senha) {
    try {
      final Usuario? usuario = usuarios.cast<Usuario?>().firstWhere(
        (u) => u?.nome == nome && u?.senha == senha,
        orElse: () => null,
      );
      return usuario != null;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }
}

class ProdutoController {
  List<Produto> produtos = [];

  Future<void> carregarProdutos() async {
    try {
      var db = await BancoHelper().db;
      var dados = await db.query("Produto");
      produtos = dados.map((e) => Produto.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao carregar produtos: $e');
      produtos = [];
    }
  }

  Future<void> editarProduto(
    int id,
    String nome,
    String unidade,
    double estoque,
    double precoVenda,
    int status,
    double custo,
    String codigoBarra,
  ) async {
    try {
      var db = await BancoHelper().db;
      Map<String, dynamic> dadosProduto = {
        'nome': nome,
        'unidade': unidade,
        'qtd_estoque': estoque,
        'preco_venda': precoVenda,
        'status': status,
        'custo': custo,
        'codigo_barra': codigoBarra,
      };
      await db.update(
        'Produto',
        dadosProduto,
        where: "id = ?",
        whereArgs: [id],
      );
      await carregarProdutos();
    } catch (e) {
      print('Erro ao editar produto: $e');
      throw e;
    }
  }

  Future<void> adicionarProduto(
    String nome,
    String unidade,
    double estoque,
    double precoVenda,
    int status,
    double custo,
    String codigoBarra,
  ) async {
    try {
      var db = await BancoHelper().db;
      Map<String, dynamic> dadosProduto = {
        'nome': nome,
        'unidade': unidade,
        'qtd_estoque': estoque,
        'preco_venda': precoVenda,
        'status': status,
        'custo': custo,
        'codigo_barra': codigoBarra,
      };
      await db.insert('Produto', dadosProduto);
      await carregarProdutos();
    } catch (e) {
      print('Erro ao adicionar produto: $e');
      throw e;
    }
  }

  Future<void> removerProduto(int id) async {
    try {
      var db = await BancoHelper().db;
      await db.delete('Produto', where: "id = ?", whereArgs: [id]);
      await carregarProdutos();
    } catch (e) {
      print('Erro ao remover produto: $e');
      throw e;
    }
  }
}

class PedidoController {
  List<Pedidos> pedidos = [];

  Future<void> carregarPedidos() async {
    try {
      var db = await BancoHelper().db;
      var dados = await db.query("Pedido");
      pedidos = dados.map((e) => Pedidos.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao carregar pedidos: $e');
      pedidos = [];
    }
  }

  Future<void> adicionarPedido(
    int idCliente,
    int idUsuario,
    double totalPedido,
    DateTime dataCriacao,
  ) async {
    try {
      var db = await BancoHelper().db;
      Map<String, dynamic> dadosPedido = {
        'id_cliente': idCliente,
        'id_usuario': idUsuario,
        'total_pedido': totalPedido,
        'data_criacao': dataCriacao.toIso8601String(),
      };
      await db.insert('Pedido', dadosPedido);
      await carregarPedidos();
    } catch (e) {
      print('Erro ao adicionar pedido: $e');
      throw e;
    }
  }

  Future<void> removerPedido(int id) async {
    try {
      var db = await BancoHelper().db;
      await db.delete('Pedido', where: "id = ?", whereArgs: [id]);
      await carregarPedidos();
    } catch (e) {
      print('Erro ao remover pedido: $e');
      throw e;
    }
  }

  Future<void> atualizarPedido(
    int id,
    int novoIdCliente,
    int novoIdUsuario,
    double novoTotalPedido,
    DateTime novaDataCriacao,
  ) async {
    try {
      var db = await BancoHelper().db;
      Map<String, dynamic> dadosPedido = {
        'id_cliente': novoIdCliente,
        'id_usuario': novoIdUsuario,
        'total_pedido': novoTotalPedido,
        'data_criacao': novaDataCriacao.toIso8601String(),
      };
      await db.update('Pedido', dadosPedido, where: "id = ?", whereArgs: [id]);
      await carregarPedidos();
    } catch (e) {
      print('Erro ao atualizar pedido: $e');
      throw e;
    }
  }
}
