import 'package:flutter/material.dart';
import 'package:trabalhon01/controladora.dart';

class TelaCadastroUsuario extends StatefulWidget {
  const TelaCadastroUsuario({super.key});

  @override
  State<TelaCadastroUsuario> createState() => _TelaCadastroUsuarioState();
}

class _TelaCadastroUsuarioState extends State<TelaCadastroUsuario> {
  final UsuarioController usuarioController = UsuarioController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Usuario> usuarios = [];
  bool _mostrarFormularioCadastro = false;
  bool _carregando = false;
  Usuario? usuarioEditando;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() => _carregando = true);

    try {
      await usuarioController.carregarUsuarios();
      setState(() {
        usuarios = usuarioController.usuarios;
      });
    } catch (e) {
      _mostrarSnackBar('Erro ao carregar usuários: $e', isError: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _salvarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      if (usuarioEditando != null) {
        await usuarioController.atualizarUsuario(
          usuarioEditando!.id,
          nomeController.text.trim(),
          senhaController.text,
        );
        _mostrarSnackBar('Usuário atualizado com sucesso!');
      } else {
        await usuarioController.adicionarUsuario(
          nomeController.text.trim(),
          senhaController.text,
        );
        _mostrarSnackBar('Usuário cadastrado com sucesso!');
      }

      _limparFormulario();
      await _carregarUsuarios();
    } catch (e) {
      _mostrarSnackBar('Erro ao salvar usuário: $e', isError: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _deletarUsuario(int id, String nome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmação'),
            content: Text('Deseja realmente excluir o usuário "$nome"?'),
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
        await usuarioController.removerUsuario(id);
        _mostrarSnackBar('Usuário excluído com sucesso!');
        await _carregarUsuarios();
      } catch (e) {
        _mostrarSnackBar('Erro ao excluir usuário: $e', isError: true);
      } finally {
        setState(() => _carregando = false);
      }
    }
  }

  void _editarUsuario(Usuario usuario) {
    setState(() {
      usuarioEditando = usuario;
      nomeController.text = usuario.nome;
      senhaController.text = usuario.senha;
      confirmarSenhaController.text = usuario.senha;
      _mostrarFormularioCadastro = true;
    });
  }

  void _limparFormulario() {
    nomeController.clear();
    senhaController.clear();
    confirmarSenhaController.clear();

    setState(() {
      usuarioEditando = null;
      _mostrarFormularioCadastro = false;
      _senhaVisivel = false;
      _confirmarSenhaVisivel = false;
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
    if (value.trim().length > 50) {
      return 'Nome deve ter no máximo 50 caracteres';
    }
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    if (value.length > 20) {
      return 'Senha deve ter no máximo 20 caracteres';
    }
    return null;
  }

  String? _validarConfirmarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != senhaController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuários'), elevation: 0),
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
                        label: const Text('Cadastrar Novo Usuário'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildListaUsuarios(),
                    ],
                    if (_mostrarFormularioCadastro) ...[
                      _buildFormularioCadastro(),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildListaUsuarios() {
    if (usuarios.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhum usuário cadastrado',
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
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final usuario = usuarios[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(usuario.nome[0].toUpperCase())),
            title: Text(usuario.nome),
            subtitle: Text('Usuário do sistema \nID: ${usuario.id}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editarUsuario(usuario),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletarUsuario(usuario.id, usuario.nome),
                ),
              ],
            ),
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
                usuarioEditando != null ? 'Editar Usuário' : 'Novo Usuário',
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
                  helperText: 'Digite o nome do usuário',
                ),
                textCapitalization: TextCapitalization.words,
                validator: _validarNome,
              ),
              const SizedBox(height: 16),

              // Senha
              TextFormField(
                controller: senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _senhaVisivel = !_senhaVisivel;
                      });
                    },
                  ),
                  helperText: 'Mínimo 6 caracteres',
                ),
                obscureText: !_senhaVisivel,
                validator: _validarSenha,
                onChanged: (value) {
                  // Revalidar confirmação de senha quando senha mudar
                  if (confirmarSenhaController.text.isNotEmpty) {
                    _formKey.currentState?.validate();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Confirmar Senha
              TextFormField(
                controller: confirmarSenhaController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmarSenhaVisivel
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
                      });
                    },
                  ),
                  helperText: 'Digite a senha novamente',
                ),
                obscureText: !_confirmarSenhaVisivel,
                validator: _validarConfirmarSenha,
              ),
              const SizedBox(height: 20),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _carregando ? null : _salvarUsuario,
                      icon: const Icon(Icons.save),
                      label: Text(
                        usuarioEditando != null ? 'Atualizar' : 'Salvar',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
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
