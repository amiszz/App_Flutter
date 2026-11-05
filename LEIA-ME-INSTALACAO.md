# Instalador para Windows — Aplicativo-Flutter-main + Firebase

## Como usar

1. **Extraia o ZIP inteiro** para uma pasta de sua escolha (nao execute de dentro do ZIP).
2. Na pasta `Aplicativo-Flutter-main`, de **dois cliques em `CONFIGURAR-FIREBASE.cmd`**.
3. Se o Windows pedir autorizacao para instalar Git ou Node.js, revise e autorize se estiver de acordo.
4. **Entre na conta Google no navegador** quando o Firebase solicitar. Utilize a conta que possui acesso ao projeto `aplicativo-flutter-main`.
5. Se o FlutterFire pedir confirmacao do registro de aplicativos Android e Web, confirme os aplicativos desejados.
6. Ao concluir, encontre o ZIP `Aplicativo-Flutter-main-Firebase-CONFIGURADO.zip` **na pasta acima** da pasta do projeto.

## O que faz

- Verifica ou instala Git pelo WinGet (se necessario).
- Baixa Flutter (inclui Dart) do repositório oficial no canal `stable`, se nao estiver disponivel.
- Verifica ou instala Node.js LTS pelo WinGet, caso nao esteja disponivel.
- Instala Firebase CLI e FlutterFire CLI pelos gerenciadores oficiais `npm` e `dart pub`.
- Adiciona pastas de ferramentas ao `PATH` **do usuario do Windows**.
- Solicita autorizacao na conta Google via `firebase login`.
- Associa as plataformas Android e Web ao projeto Firebase (`flutterfire configure`).
- Resolve dependencias Flutter, roda diagnosticos e tenta compilar para Web.
- Gera o ZIP final sem caches e sem os arquivos temporarios de build.

## Importante

- O script **nao roda no computador do assistente ou remotamente**: os comandos executam no Windows ao clicar no `.cmd`.
- Nenhum servidor Firebase sera hospedado no computador, e o script nao faz deploy na internet.
- Se o `winget` nao existir, instale ou atualize o 'Instalador de Aplicativo' na Microsoft Store, ou instale Git e Node.js manualmente e execute novamente.
- Pode ser preciso conceder permissao de administrador aos instaladores do Git/Node.js, dependendo de como seu Windows estiver configurado.
- Para compilar para Android, `flutter doctor` pode exigir Android Studio, Android SDK e licencas Android; eles **nao** sao instalados por este script. Para testar a versao Web no Chrome, nao sao necessarios.
- Antes de publicar o Android, substitua o identificador generico `com.example.app_flutter` por um identificador exclusivo e execute o FlutterFire novamente para registrar a app Android correta.
- A configuracao publica em `lib/firebase_options.dart` **nao e uma credencial de administrador**. Nunca coloque chaves de conta de servico ou arquivos de credenciais privadas no ZIP/repositório.
- Se as validacoes `flutter analyze`, `flutter test` ou `flutter build web` reportarem erros, a conectividade Firebase pode estar configurada, mas a compilacao ainda precisa ser corrigida.


## Correcao automatica: Windows bloqueia symlinks

Quando aparecer `Building with plugins requires symlink support`, nao e necessario reinstalar as ferramentas.

Esta versao do instalador agora **testa se o Windows permite criar symlinks** antes do `flutter pub get`. Se houver bloqueio:

1. O instalador abre a pagina `ms-settings:developers` do Windows.
2. Voce ativa o **Modo de Desenvolvedor** e confirma a alteracao (exige permissao administrativa).
3. Volta a janela do instalador e pressiona ENTER. O teste e repetido e o script prossegue sem reinstalar as ferramentas.

O instalador **nao ativa essa opcao de seguranca automaticamente**. Em dispositivos de trabalho administrados, voce pode precisar falar com o administrador.

Se ja tiver ativado o modo de desenvolvedor com a versao anterior, basta executar `CONFIGURAR-FIREBASE.cmd` novamente.

Documentacao Microsoft: https://learn.microsoft.com/en-us/windows/advanced-settings/developer-mode

## Finalizacao sem reinstalar ou reconfigurar (importante)

Se a instalacao ja exibiu `No issues found!`, `All tests passed!` e `Built build\web`, mas falhou com `FlutterGeneratedPluginSwiftPackage.swift`, **o projeto ja passou nas validacoes** e a falha veio da antiga exportacao ZIP.

Nao extraia um novo ZIP completo sobre seu projeto configurado: isso pode substituir arquivos locais. Em vez disso, coloque **somente** `FINALIZAR-COMPARTILHAMENTO.cmd` e `FINALIZAR-COMPARTILHAMENTO.ps1` dentro da pasta atual do projeto (onde fica `pubspec.yaml`) e execute o `.cmd`.

Essa acao **nao reinstala Flutter, nao refaz login, nao altera o Firebase e nao recompila o aplicativo**. Apenas monta `Aplicativo-Flutter-main-Firebase-CONFIGURADO.zip` na pasta acima, incluindo `lib/firebase_options.dart`, mas sem `ios/Flutter/ephemeral`, `macos/Flutter/ephemeral`, pastas de cache, links simbolicos e arquivos de credenciais privadas comuns.

A plataforma Web compilada ja esta em `build\web` e pode ser publicada separadamente.

## Alternativa manual / solucao de problemas

No terminal PowerShell, na pasta do projeto:

```powershell
flutter --version
dart --version
firebase --version
flutterfire --version
flutterfire configure --project=aplicativo-flutter-main --platforms=android,web
flutter run -d chrome
```

Em caso de erro durante `firebase login`, confira se a conta Google possui permissao no projeto Firebase. A rede/proxy corporativo tambem pode interferir no download e na autenticacao.

Documentacao oficial:
- https://docs.flutter.dev/install/with-vs-code
- https://docs.flutter.dev/install/manual
- https://firebase.google.com/docs/cli
- https://firebase.google.com/docs/flutter/setup
