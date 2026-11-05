import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();
  bool _carregando = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate() || _carregando) return;
    setState(() => _carregando = true);
    try {
      await AuthService.cadastrar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      if (!mounted) return;
      // Volta para a rota raiz; AuthGate já terá detectado a nova sessão.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (erro) {
      _mostrarErro(mensagemErroAutenticacao(erro));
    } catch (_) {
      _mostrarErro('Erro inesperado. Verifique sua conexão e tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 25),
                const Icon(
                  Icons.person_add_alt_1,
                  size: 65,
                  color: Color(0xFFC17B36),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Faça seu cadastro',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B3F2A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preencha os dados para criar sua conta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF806B5C)),
                ),
                const SizedBox(height: 35),
                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: (nome) => (nome == null || nome.trim().isEmpty)
                      ? 'Informe seu nome.'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: validarEmail,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.mail_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _senhaController,
                  obscureText: _ocultarSenha,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (senha) {
                    if (senha == null || senha.isEmpty) {
                      return 'Informe uma senha.';
                    }
                    if (senha.length < 6) {
                      return 'Use pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                      icon: Icon(
                        _ocultarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _confirmacaoController,
                  obscureText: _ocultarSenha,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => _cadastrar(),
                  validator: (confirmacao) {
                    if (confirmacao == null || confirmacao.isEmpty) {
                      return 'Confirme sua senha.';
                    }
                    if (confirmacao != _senhaController.text) {
                      return 'As senhas não coincidem.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirmar senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA64B2A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _carregando ? null : _cadastrar,
                    child: _carregando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: _carregando ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Já possui conta? Faça login',
                    style: TextStyle(color: Color(0xFF6B3F2A)),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.eco_outlined,
                  color: Color(0xFFC17B36),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
