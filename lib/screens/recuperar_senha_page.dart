import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _enviando = false;
  bool _concluido = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate() || _enviando) return;
    setState(() => _enviando = true);
    try {
      await AuthService.recuperarSenha(_emailController.text.trim());
      if (mounted) setState(() => _concluido = true);
    } on FirebaseAuthException catch (erro) {
      // Em projetos com proteção contra enumeração, não revelar se a conta existe.
      if (erro.code == 'user-not-found') {
        if (mounted) setState(() => _concluido = true);
      } else {
        _mostrarErro(mensagemErroAutenticacao(erro));
      }
    } catch (_) {
      _mostrarErro('Não foi possível enviar. Verifique sua conexão.');
    } finally {
      if (mounted) setState(() => _enviando = false);
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
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 65,
                  color: Color(0xFFC17B36),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Redefinir senha',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B3F2A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _concluido
                      ? 'Se houver uma conta vinculada a este e-mail, você receberá as instruções para redefinir a senha.'
                      : 'Informe seu e-mail para receber instruções de recuperação.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF806B5C)),
                ),
                const SizedBox(height: 30),
                if (!_concluido) ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _enviando ? null : _enviar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA64B2A),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_enviando ? 'Enviando...' : 'Enviar e-mail'),
                    ),
                  ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Voltar ao login'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
