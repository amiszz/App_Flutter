## Instalacao facilitada

No Windows, execute `CONFIGURAR-FIREBASE.cmd` na raiz do projeto; veja `LEIA-ME-INSTALACAO.md`. O restante deste documento explica o processo manual.

# Firebase — configuração obrigatória neste computador

## O que foi integrado

A estrutura enviada possuía telas de login/cadastro com `onPressed: () {}` (sem lógica). Foi implementado:

- Firebase Authentication com e-mail e senha;
- cadastro de usuário e atualização do nome de exibição (`displayName`);
- login com validação de formulário e mensagens de erros;
- restauração de sessão / entrada automática enquanto conectado;
- tela inicial de demonstração e saída da conta;
- recuperação de senha por e-mail;
- estado de carregamento e prevenção de toques repetidos;
- permissão de acesso à internet em Android release e Android `minSdk = 24`.

## Passos no Windows com VS Code

**O aplicativo ainda NÃO está vinculado à sua conta pessoal do Firebase.** É preciso criar as configurações específicas do app pela sua conta. Não incluímos opções fictícias nem chaves inventadas.

1. Extraia o ZIP, abra a pasta **Aplicativo-Flutter-main** no VS Code e abra o terminal na raiz (onde está `pubspec.yaml`).
2. Confira as instalações de Flutter e Node.js:

   ```powershell
   flutter doctor
   node --version
   npm --version
   ```

3. Instale o Firebase CLI e faça login com a MESMA conta Google que tem acesso ao projeto:

   ```powershell
   npm install -g firebase-tools
   firebase login
   ```

4. Instale o FlutterFire CLI e, se `flutterfire` não for encontrado no PowerShell, adicione o diretório de executáveis do Dart ao PATH **desta sessão**:

   ```powershell
   dart pub global activate flutterfire_cli
   $env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin"
   ```

5. Instale as dependências e vincule as plataformas que você deseja usar (comando abaixo para Android e Web):

   ```powershell
   flutter pub get
   flutterfire configure --project=aplicativo-flutter-main --platforms=android,web
   ```

   Esse comando cria o arquivo `lib/firebase_options.dart` com os IDs e opções reais da sua conta. Ele também registra ou associa as apps correspondentes no projeto Firebase e pode atualizar configurações específicas da plataforma. **Não crie esse arquivo manualmente nem substitua por credenciais falsas.**

6. Inicie no dispositivo ou emulador:

   ```powershell
   flutter devices
   flutter run
   ```

   Para executar no Chrome, use `flutter run -d chrome`, se o Flutter Web estiver habilitado.

7. Teste o cadastro de um e-mail novo. Em seguida, confira no Console Firebase: **Authentication → Usuários**. Teste depois sair, entrar de novo e receber e-mail de recuperação.

## Conferências essenciais no Console

- Projeto Firebase na URL fornecida: `aplicativo-flutter-main`.
- **Authentication → Método de login → E-mail/senha**: já aparece como ativado no print enviado.
- **Configurações do projeto → Seus aplicativos**: registre o Android pelo ID exato `com.example.app_flutter` se não usar o CLI. Esse valor vem de `android/app/build.gradle.kts`.
- Para Flutter Web, tenha também um aplicativo Web associado pelo CLI e confira os domínios autorizados em Authentication → Configurações.
- Se alterar `applicationId`, reexecute `flutterfire configure` para vincular a app correta.

## Arquivos principais

- `lib/main.dart`: inicialização Firebase com `DefaultFirebaseOptions.currentPlatform`.
- `lib/services/auth_service.dart`: métodos de autenticação/validações.
- `lib/screens/auth_gate.dart`: roteamento conforme estado da sessão.
- `lib/screens/login_page.dart`: entrada.
- `lib/screens/cadastro_page.dart`: registro.
- `lib/screens/recuperar_senha_page.dart`: recuperação.
- `lib/screens/home_page.dart`: área autenticada de exemplo para substituir por sua tela real.

## Dependências

- `firebase_core: ^5.1.0`
- `firebase_auth: ^7.0.1`

Versões com suporte documentado em FlutterFire BoM de outubro de 2026. O `pubspec.lock` será resolvido/atualizado pelo `flutter pub get` executado no seu ambiente.

## Segurança e produção

- Use Firebase Authentication para contas; **nunca** salve senhas em Firestore, preferências locais ou no código.
- As configurações geradas em `firebase_options.dart` identificam seu aplicativo, mas não substituem as regras de segurança dos serviços Firebase.
- Se adicionar Firestore ou Storage depois, implemente regras de acesso por usuário e teste-as antes de publicar.
- A `home_page.dart` é uma tela provisória, não a funcionalidade final do aplicativo.
- A integração do código foi preparada, mas **não foi possível executar `flutter pub get`, `flutter analyze`, `flutter test` ou `flutter run` aqui porque o SDK Flutter/Dart não está instalado neste ambiente**. Valide em seu computador após o `flutterfire configure`.

## Problemas comuns

- `Target of URI doesn't exist: 'firebase_options.dart'`: falta executar `flutterfire configure`.
- `flutterfire: command not found`: revise o PATH da pasta Pub Cache e reinicie o terminal.
- `firebase` não reconhecido: instale o `firebase-tools` via npm.
- `PERMISSION_DENIED` em banco de dados: configure as regras próprias do Firestore (não tem relação direta com login).
- `operation-not-allowed`: habilite o provedor E-mail/senha no Authentication do mesmo projeto selecionado.
- `No Firebase App '[DEFAULT]' has been created`: confirme que `Firebase.initializeApp` foi executado antes de utilizar o `FirebaseAuth`.

Documentação oficial:
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/auth/flutter/password-auth
- https://firebase.google.com/docs/auth/flutter/manage-users
