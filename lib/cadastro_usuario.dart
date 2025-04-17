import 'package:flutter/material.dart';
import 'package:trabalhon01/controladora.dart' as controladora;
import 'package:trabalhon01/tela_shared.dart' as controladora;

class TelaCadastroUsuario extends StatefulWidget {
  const TelaCadastroUsuario({super.key});

  @override
  State<TelaCadastroUsuario> createState() => _TelaCadastroUsuarioState();
}

class _TelaCadastroUsuarioState extends State<TelaCadastroUsuario> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final controladora.UsuarioManager usuarioController =
      controladora.UsuarioManager();
  List<controladora.Usuario> usuarios = [];
  bool _mostrarFormularioCadastro = false;
  controladora.Usuario? usuarioEditando;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    await usuarioController.carregarUsuarios();
    setState(() {
      usuarios = usuarioController.usuarios;
    });
  }

  void salvar() async {
    if (nomeController.text.isEmpty || senhaController.text.isEmpty) return;

    if (usuarioEditando != null) {
      usuarioController.atualizarUsuario(
        usuarioEditando!.id,
        nomeController.text,
        senhaController.text,
      );
    } else {
      usuarioController.adicionarUsuario(
        nomeController.text,
        senhaController.text,
      );
    }

    await usuarioController.salvarUsuarios();

    nomeController.clear();
    senhaController.clear();

    setState(() {
      usuarioEditando = null;
      _mostrarFormularioCadastro = false;
    });

    carregar();
  }

  void deletar(int id) async {
    usuarioController.removerUsuario(id);
    await usuarioController.salvarUsuarios();
    carregar();
  }

  void editarUsuario(controladora.Usuario usuario) {
    setState(() {
      usuarioEditando = usuario;
      nomeController.text = usuario.nome;
      senhaController.text = usuario.senha;
      _mostrarFormularioCadastro = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuários')),
      body: Padding(
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
                child: const Text('Cadastrar Novo Usuário'),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final usuario = usuarios[index];
                  return ListTile(
                    title: Text(usuario.nome),
                    onTap: () => editarUsuario(usuario),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deletar(usuario.id),
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
                controller: senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
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
