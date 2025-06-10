import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Pedidos {
  int id;
  int idUsuario;
  int idCliente;
  double totalPedido;
  DateTime dataCriacao;
  List<PedidoItem> itens;
  List<PedidoPagamento> pagamentos;

  Pedidos({
    required this.id,
    required this.idUsuario,
    required this.idCliente,
    required this.totalPedido,
    required this.dataCriacao,
    this.itens = const [],
    this.pagamentos = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'idUsuario': idUsuario,
    'idCliente': idCliente,
    'totalPedido': totalPedido,
    'dataCriacao': dataCriacao.toIso8601String(),
    'itens': itens.map((item) => item.toJson()).toList(),
    'pagamentos': pagamentos.map((pagamento) => pagamento.toJson()).toList(),
  };

  factory Pedidos.fromJson(Map<String, dynamic> json) => Pedidos(
    id: json['id'],
    idUsuario: json['idUsuario'],
    idCliente: json['idCliente'],
    totalPedido: json['totalPedido'],
    dataCriacao: DateTime.parse(json['dataCriacao']),
    itens:
        (json['itens'] as List<dynamic>?)
            ?.map((itemJson) => PedidoItem.fromJson(itemJson))
            .toList() ??
        [],
    pagamentos:
        (json['pagamentos'] as List<dynamic>?)
            ?.map((pagamentoJson) => PedidoPagamento.fromJson(pagamentoJson))
            .toList() ??
        [],
  );
}

class PedidoItem {
  int idPedido;
  int id;
  int idProduto;
  int quantidade;
  double totalItem;

  PedidoItem({
    required this.idPedido,
    required this.id,
    required this.idProduto,
    required this.quantidade,
    required this.totalItem,
  });

  Map<String, dynamic> toJson() => {
    'idPedido': idPedido,
    'id': id,
    'idProduto': idProduto,
    'quantidade': quantidade,
    'totalItem': totalItem,
  };

  factory PedidoItem.fromJson(Map<String, dynamic> json) => PedidoItem(
    idPedido: json['idPedido'],
    id: json['id'],
    idProduto: json['idProduto'],
    quantidade: json['quantidade'],
    totalItem: json['totalItem'],
  );
}

class PedidoPagamento {
  int idPedido;
  int id;
  double valorPagamento;

  PedidoPagamento({
    required this.idPedido,
    required this.id,
    required this.valorPagamento,
  });

  Map<String, dynamic> toJson() => {
    'idPedido': idPedido,
    'id': id,
    'valorPagamento': valorPagamento,
  };

  factory PedidoPagamento.fromJson(Map<String, dynamic> json) =>
      PedidoPagamento(
        idPedido: json['idPedido'],
        id: json['id'],
        valorPagamento: json['valorPagamento'],
      );
}

class Usuario {
  int id;
  String nome;
  String senha;

  Usuario({required this.id, required this.nome, required this.senha});

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'senha': senha};

  factory Usuario.fromJson(Map<String, dynamic> json) =>
      Usuario(id: json['id'], nome: json['nome'], senha: json['senha']);
}

class Cliente {
  int id;
  String nome;
  String tipo;
  String documento;
  String email;
  String telefone;
  String cep;
  String endereco;
  String bairro;
  String cidade;
  String uf;

  Cliente({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.documento,
    required this.email,
    required this.telefone,
    required this.cep,
    required this.endereco,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
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

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json['id'],
    nome: json['nome'],
    tipo: json['tipo'],
    documento: json['cpf_cnpj'],
    email: json['email'],
    telefone: json['telefone'],
    cep: json['cep'],
    endereco: json['endereco'],
    bairro: json['bairro'],
    cidade: json['cidade'],
    uf: json['uf'],
  );
}

class Produto {
  int id;
  String nome;
  String unidade;
  double estoque;
  double precoVenda;
  int status;
  double custo;
  String codigoBarra;

  Produto({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.estoque,
    required this.precoVenda,
    required this.status,
    required this.custo,
    required this.codigoBarra,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'unidade': unidade,
    'qtd_estoque': estoque,
    'preco_venda': precoVenda,
    'status': status,
    'custo': custo,
    'codigo_barra': codigoBarra,
  };

  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
    id: json['id'],
    nome: json['nome'],
    unidade: json['unidade'],
    estoque: json['qtd_estoque'],
    precoVenda: json['preco_venda'],
    status: json['status'],
    custo: json['custo'],
    codigoBarra: json['codigo_barra'],
  );
}
