import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BancoHelper {
  Database? _database;
  Future<Database> get db async => await initDB();

  Future<Database> initDB() async {
    if (_database == null) {
      String path = await getDatabasesPath();
      path = join(path, 'banco.db');
      _database = await openDatabase(
        path,
        version: 2,
        onCreate: _onCreateDB,
        onUpgrade: _onUpgradeDB,
      );
    }
    return _database!;
  }

  FutureOr<void> _onCreateDB(Database db, int version) async {
    //Tabela usuario
    await db.execute(
      "CREATE TABLE Usuario (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT not null, senha TEXT)",
    );

    //Tabela produto
    await db.execute('''
    CREATE TABLE Produto (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      unidade TEXT NOT NULL CHECK (unidade IN ('un', 'cx', 'kg', 'lt', 'ml')),
      qtd_estoque REAL NOT NULL DEFAULT 0,
      preco_venda REAL NOT NULL,
      status INTEGER NOT NULL DEFAULT 0 CHECK (status IN (0, 1)),  -- 0 = Ativo, 1 = Inativo
      custo REAL,
      codigo_barra TEXT
    )
    ''');

    //Tabela Cliente
    await db.execute('''
    CREATE TABLE Cliente (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      tipo TEXT NOT NULL CHECK (tipo IN ('F', 'J')),  -- F = Física, J = Jurídica
      cpf_cnpj TEXT NOT NULL UNIQUE,
      email TEXT,
      telefone TEXT,
      cep TEXT,
      endereco TEXT,
      bairro TEXT,
      cidade TEXT,
      uf TEXT
    )
    ''');

    //Tabela Pedido
    await db.execute('''
    CREATE TABLE Pedido (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_cliente INTEGER NOT NULL,
      id_usuario INTEGER NOT NULL,
      total_pedido REAL NOT NULL,
      data_criacao TEXT NOT NULL,
      FOREIGN KEY (id_cliente) REFERENCES Cliente (id),
      FOREIGN KEY (id_usuario) REFERENCES Usuario (id)
    )
    ''');

    //Tabela ItemPedido
    await db.execute('''
    CREATE TABLE ItemPedido (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_pedido INTEGER NOT NULL,
      id_produto INTEGER NOT NULL,
      quantidade REAL NOT NULL,
      preco_unitario REAL NOT NULL,
      FOREIGN KEY (id_pedido) REFERENCES Pedido (id) ON DELETE CASCADE,
      FOREIGN KEY (id_produto) REFERENCES Produto (id)
    )
    ''');

    //Tabela Pagamento
    await db.execute('''
    CREATE TABLE Pagamento (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_pedido INTEGER NOT NULL,
      forma_pagamento TEXT NOT NULL,
      valor REAL NOT NULL,
      data_pagamento TEXT NOT NULL,
      FOREIGN KEY (id_pedido) REFERENCES Pedido (id) ON DELETE CASCADE
    )
    ''');
  }

  FutureOr<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) {}
}
