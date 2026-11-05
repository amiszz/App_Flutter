import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'cadastro_page.dart';
import 'recuperar_senha_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate() || _carregando) return;
    setState(() => _carregando = true);
    try {
      await AuthService.entrar(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      // O AuthGate detecta o login e abre a tela inicial.
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 55),
                const Icon(
                  Icons.wb_sunny_outlined,
                  size: 65,
                  color: Color(0xFFC17B36),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Bem-vindo!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B3F2A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entre na sua conta para continuar.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF806B5C)),
                ),
                const SizedBox(height: 40),
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
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _entrar(),
                  validator: (senha) => (senha == null || senha.isEmpty)
                      ? 'Informe sua senha.'
                      : null,
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
                    onPressed: _carregando ? null : _entrar,
                    child: _carregando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Entrar', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _carregando
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const RecuperarSenhaPage(),
                            ),
                          ),
                  child: const Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(color: Color(0xFF6B3F2A)),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: _carregando
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const CadastroPage(),
                            ),
                          ),
                  child: const Text(
                    'Não possui conta? Cadastre-se',
                    style: TextStyle(color: Color(0xFF6B3F2A)),
                  ),
                ),
                const SizedBox(height: 35),
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
