import 'dart:convert';
import 'package:trabalhon01/banco.dart';
import 'package:http/http.dart' as http;

class Cliente {
  final int id;
  final String nome;
  final String tipo;
  final String cpfCnpj;
  final String email;
  final String telefone;
  final String cep;
  final String endereco;
  final String bairro;
  final String cidade;
  final String uf;

  Cliente({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.cpfCnpj,
    required this.email,
    required this.telefone,
    required this.cep,
    required this.endereco,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? '',
      cpfCnpj: json['cpf_cnpj'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      cep: json['cep'] ?? '',
      endereco: json['endereco'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      uf: json['uf'] ?? '',
    );
  }
}

class Usuario {
  final int id;
  final String nome;
  final String senha;
  // DateTime? ultimaAlteracao;

  Usuario({
    required this.id,
    required this.nome,
    required this.senha,
    // required this.ultimaAlteracao,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      senha: json['senha'] ?? '',
      // ultimaAlteracao: DateTime.parse(json['ultimaAlteracao']),
    );
  }
}

class Produto {
  final int id;
  final String nome;
  final String unidade;
  final double qtdEstoque;
  final double precoVenda;
  final int status;
  final double custo;
  final String codigoBarra;

  Produto({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.qtdEstoque,
    required this.precoVenda,
    required this.status,
    required this.custo,
    required this.codigoBarra,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      unidade: json['unidade'] ?? '',
      qtdEstoque: (json['qtd_estoque'] ?? 0).toDouble(),
      precoVenda: (json['preco_venda'] ?? 0).toDouble(),
      status: json['status'] ?? 0,
      custo: (json['custo'] ?? 0).toDouble(),
      codigoBarra: json['codigo_barra'] ?? '',
    );
  }
}

class Pedidos {
  final int id;
  final int idCliente;
  final int idUsuario;
  final double totalPedido;
  final DateTime dataCriacao;

  Pedidos({
    required this.id,
    required this.idCliente,
    required this.idUsuario,
    required this.totalPedido,
    required this.dataCriacao,
  });

  factory Pedidos.fromJson(Map<String, dynamic> json) {
    return Pedidos(
      id: json['id'] ?? 0,
      idCliente: json['id_cliente'] ?? 0,
      idUsuario: json['id_usuario'] ?? 0,
      totalPedido: (json['total_pedido'] ?? 0).toDouble(),
      dataCriacao:
          DateTime.tryParse(json['data_criacao'] ?? '') ?? DateTime.now(),
    );
  }
}

class ItemPedido {
  final int? id;
  final int idPedido;
  final int idProduto;
  final double quantidade;
  final double precoUnitario;
  final double total;

  ItemPedido({
    this.id,
    required this.idPedido,
    required this.idProduto,
    required this.quantidade,
    required this.precoUnitario,
    required this.total,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      id: json['id'],
      idPedido: json['id_pedido'] ?? 0,
      idProduto: json['id_produto'] ?? 0,
      quantidade: (json['quantidade'] ?? 0).toDouble(),
      precoUnitario: (json['preco_unitario'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pedido': idPedido,
      'id_produto': idProduto,
      'quantidade': quantidade,
      'preco_unitario': precoUnitario,
      'total': total,
    };
  }
}

class PagamentoPedido {
  final int? id;
  final int idPedido;
  final String tipo;
  final double valor;
  final String descricao;

  PagamentoPedido({
    this.id,
    required this.idPedido,
    required this.tipo,
    required this.valor,
    required this.descricao,
  });

  factory PagamentoPedido.fromJson(Map<String, dynamic> json) {
    return PagamentoPedido(
      id: json['id'],
      idPedido: json['id_pedido'] ?? 0,
      tipo: json['tipo'] ?? '',
      valor: (json['valor'] ?? 0).toDouble(),
      descricao: json['descricao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pedido': idPedido,
      'tipo': tipo,
      'valor': valor,
      'descricao': descricao,
    };
  }
}

class ClienteController {
  List<Cliente> clientes = [];

  Future<void> carregarClientes() async {
    try {
      var db = await BancoHelper().db;
      var dados = await db.query("Cliente");
      clientes = dados.map((e) => Cliente.fromJson(e)).toList();
    } catch (e) {
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
      rethrow;
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
      rethrow;
    }
  }

  Future<void> removerCliente(int id) async {
    try {
      var db = await BancoHelper().db;
      await db.delete('Cliente', where: "id = ?", whereArgs: [id]);
      await carregarClientes();
    } catch (e) {
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }

  Future<void> removerUsuario(int id) async {
    try {
      var db = await BancoHelper().db;
      await db.delete('Usuario', where: "id = ?", whereArgs: [id]);
      await carregarUsuarios();
    } catch (e) {
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }

  Future<void> removerProduto(int id) async {
    try {
      var db = await BancoHelper().db;
      await db.delete('Produto', where: "id = ?", whereArgs: [id]);
      await carregarProdutos();
    } catch (e) {
      rethrow;
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
      pedidos = [];
    }
  }

  Future<int> adicionarPedido(
    int idCliente,
    int idUsuario,
    double totalPedido,
    DateTime dataCriacao,
    List<ItemPedido> itens,
    List<PagamentoPedido> pagamentos,
  ) async {
    var db = await BancoHelper().db;

    try {
      Map<String, dynamic> dadosPedido = {
        'id_cliente': idCliente,
        'id_usuario': idUsuario,
        'total_pedido': totalPedido,
        'data_criacao': dataCriacao.toIso8601String(),
      };

      int idPedido = await db.insert('Pedido', dadosPedido);

      for (ItemPedido item in itens) {
        Map<String, dynamic> dadosItem = {
          'id_pedido': idPedido,
          'id_produto': item.idProduto,
          'quantidade': item.quantidade,
          'preco_unitario': item.precoUnitario,
          'total': item.total,
        };
        await db.insert('ItemPedido', dadosItem);
      }

      for (PagamentoPedido pagamento in pagamentos) {
        Map<String, dynamic> dadosPagamento = {
          'id_pedido': idPedido,
          'tipo': pagamento.tipo,
          'valor': pagamento.valor,
          'descricao': pagamento.descricao,
        };
        await db.insert('PagamentoPedido', dadosPagamento);
      }

      await carregarPedidos();
      return idPedido;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removerPedido(int id) async {
    var db = await BancoHelper().db;

    try {
      await db.delete(
        'PagamentoPedido',
        where: 'id_pedido = ?',
        whereArgs: [id],
      );
      await db.delete('ItemPedido', where: 'id_pedido = ?', whereArgs: [id]);
      await db.delete('Pedido', where: "id = ?", whereArgs: [id]);
      await carregarPedidos();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> atualizarPedido(
    int id,
    int novoIdCliente,
    int novoIdUsuario,
    double novoTotalPedido,
    DateTime novaDataCriacao,
    List<ItemPedido> novosItens,
    List<PagamentoPedido> novosPagamentos,
  ) async {
    var db = await BancoHelper().db;

    try {
      Map<String, dynamic> dadosPedido = {
        'id_cliente': novoIdCliente,
        'id_usuario': novoIdUsuario,
        'total_pedido': novoTotalPedido,
        'data_criacao': novaDataCriacao.toIso8601String(),
      };

      await db.update('Pedido', dadosPedido, where: "id = ?", whereArgs: [id]);
      await db.delete('ItemPedido', where: 'id_pedido = ?', whereArgs: [id]);
      await db.delete(
        'PagamentoPedido',
        where: 'id_pedido = ?',
        whereArgs: [id],
      );

      for (ItemPedido item in novosItens) {
        Map<String, dynamic> dadosItem = {
          'id_pedido': id,
          'id_produto': item.idProduto,
          'quantidade': item.quantidade,
          'preco_unitario': item.precoUnitario,
          'total': item.total,
        };
        await db.insert('ItemPedido', dadosItem);
      }

      for (PagamentoPedido pagamento in novosPagamentos) {
        Map<String, dynamic> dadosPagamento = {
          'id_pedido': id,
          'tipo': pagamento.tipo,
          'valor': pagamento.valor,
          'descricao': pagamento.descricao,
        };
        await db.insert('PagamentoPedido', dadosPagamento);
      }

      await carregarPedidos();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ItemPedido>> carregarItensPedido(int idPedido) async {
    try {
      var db = await BancoHelper().db;
      var dados = await db.query(
        'ItemPedido',
        where: 'id_pedido = ?',
        whereArgs: [idPedido],
      );
      return dados.map((e) => ItemPedido.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PagamentoPedido>> carregarPagamentosPedido(int idPedido) async {
    try {
      var db = await BancoHelper().db;
      var dados = await db.query(
        'PagamentoPedido',
        where: 'id_pedido = ?',
        whereArgs: [idPedido],
      );
      return dados.map((e) => PagamentoPedido.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}

class ViaCepService {
  static Future<Map<String, dynamic>?> buscarCep(String cep) async {
    if (cep.length != 8) {
      throw Exception('CEP deve conter 8 dígitos');
    }

    try {
      final response = await http
          .get(
            Uri.parse('https://viacep.com.br/ws/$cep/json/'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final Map<String, dynamic> dados = json.decode(response.body);

        if (dados.containsKey('erro') && dados['erro'] == true) {
          throw Exception('CEP não encontrado');
        }

        return {
          'cep': dados['cep'] ?? '',
          'logradouro': dados['logradouro'] ?? '',
          'complemento': dados['complemento'] ?? '',
          'bairro': dados['bairro'] ?? '',
          'localidade': dados['localidade'] ?? '',
          'uf': dados['uf'] ?? '',
        };
      } else {
        throw Exception('Erro na consulta: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout na consulta do CEP');
      }
      rethrow;
    }
  }
}
