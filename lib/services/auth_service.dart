import 'package:firebase_auth/firebase_auth.dart';

/// Operações de autenticação concentradas em um só lugar.
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> get usuarioAtual => _auth.userChanges();

  static Future<void> entrar({
    required String email,
    required String senha,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  static Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    // A conta já foi criada neste ponto. Falha ao salvar nome não deve
    // ser confundida com falha ao criar a conta e causar um novo cadastro.
    try {
      await credencial.user?.updateDisplayName(nome);
    } on FirebaseAuthException {
      // Nome é um atributo opcional; o login continua válido.
    }
  }

  static Future<void> recuperarSenha(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> sair() => _auth.signOut();
}

String? validarEmail(String? valor) {
  final email = (valor ?? '').trim();
  if (email.isEmpty) return 'Informe seu e-mail.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Digite um e-mail válido.';
  }
  return null;
}

/// Mensagens legíveis sem expor detalhes internos ou segredos de login.
String mensagemErroAutenticacao(FirebaseAuthException erro) {
  switch (erro.code) {
    case 'invalid-email':
      return 'O endereço de e-mail é inválido.';
    case 'email-already-in-use':
      return 'Este e-mail já está cadastrado.';
    case 'weak-password':
      return 'Senha fraca. Escolha uma senha mais segura.';
    case 'wrong-password':
    case 'user-not-found':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return 'E-mail ou senha inválidos.';
    case 'user-disabled':
      return 'Esta conta foi desativada.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde e tente novamente.';
    case 'network-request-failed':
      return 'Falha de conexão. Verifique sua internet.';
    case 'operation-not-allowed':
      return 'Login por e-mail/senha não está habilitado no Firebase.';
    default:
      return 'Não foi possível concluir a operação. Tente novamente.';
  }
}
