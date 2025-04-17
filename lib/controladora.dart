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
    'documento': documento,
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
    documento: json['documento'],
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
  int estoque;
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
    'estoque': estoque,
    'precoVenda': precoVenda,
    'status': status,
    'custo': custo,
    'codigoBarra': codigoBarra,
  };

  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
    id: json['id'],
    nome: json['nome'],
    unidade: json['unidade'],
    estoque: json['estoque'],
    precoVenda: json['precoVenda'],
    status: json['status'],
    custo: json['custo'],
    codigoBarra: json['codigoBarra'],
  );
}
