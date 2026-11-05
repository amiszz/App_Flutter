import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Tela inicial provisória para confirmar que a autenticação funcionou.
/// Substitua pelo conteúdo principal do aplicativo quando estiver disponível.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.usuario});

  final User usuario;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _saindo = false;

  Future<void> _sair() async {
    setState(() => _saindo = true);
    try {
      await AuthService.sair();
      // AuthGate observa a sessão e retorna automaticamente ao login.
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível sair. Tente novamente.')),
      );
    } finally {
      if (mounted) setState(() => _saindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.usuario.displayName?.trim();
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFFC17B36),
                  size: 72,
                ),
                const SizedBox(height: 18),
                Text(
                  nome != null && nome.isNotEmpty
                      ? 'Olá, $nome!'
                      : 'Login realizado!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B3F2A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.usuario.email ?? 'Conta autenticada',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF806B5C)),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _saindo ? null : _sair,
                    icon: const Icon(Icons.logout),
                    label: Text(_saindo ? 'Saindo...' : 'Sair da conta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA64B2A),
                      foregroundColor: Colors.white,
                    ),
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
