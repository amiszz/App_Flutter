#Requires -Version 5.1
<#
  Instalador assistido do projeto Aplicativo-Flutter-main.
  Execute pelo CONFIGURAR-FIREBASE.cmd, na pasta que contem pubspec.yaml.
  Instala ferramentas oficiais no SEU Windows e solicita login no Firebase.
  Nao instala servidor local, nao faz deploy nem pede senhas neste script.
#>
[CmdletBinding()]
param([switch]$PularBuildWeb)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Aviso([string]$Mensagem) { Write-Host "`n==> $Mensagem" -ForegroundColor Cyan }
function Interromper([string]$Mensagem) { throw $Mensagem }

function Atualizar-Path {
  $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  $paths = @($machinePath, $userPath, $env:Path,
    "$env:ProgramFiles\Git\cmd", "$env:LOCALAPPDATA\Programs\Git\cmd",
    "$env:ProgramFiles\nodejs", "$env:LOCALAPPDATA\Programs\nodejs",
    "$env:APPDATA\npm", "$env:LOCALAPPDATA\Pub\Cache\bin")
  $env:Path = (($paths | Where-Object { $_ -and $_.Trim() }) -join ';')
}

function Adicionar-PathUsuario([string]$Diretorio) {
  $atual = [Environment]::GetEnvironmentVariable('Path', 'User')
  $partes = @($atual -split ';' | Where-Object { $_.Trim() })
  if ($partes -notcontains $Diretorio) {
    $novo = (($partes + $Diretorio) -join ';')
    [Environment]::SetEnvironmentVariable('Path', $novo, 'User')
  }
  Atualizar-Path
}

function Executar([string]$Programa, [string[]]$Argumentos, [switch]$PermitirErro) {
  & $Programa @Argumentos
  $codigo = $LASTEXITCODE
  if ($codigo -ne 0 -and -not $PermitirErro) {
    Interromper "O comando '$Programa $($Argumentos -join ' ')' retornou codigo $codigo. Veja o erro acima."
  }
  $script:UltimoCodigo = $codigo
}

function Comando([string]$Nome) {
  $info = Get-Command $Nome -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($info) { return $info.Source }
  return $null
}


function Testar-Symlinks {
  # Testa a permissao efetiva; evita confiar apenas em chaves de Registro.
  $dirTeste = Join-Path ([IO.Path]::GetTempPath()) ('flutter-symlinks-' + [guid]::NewGuid().ToString('N'))
  try {
    New-Item -ItemType Directory -Path $dirTeste -Force -ErrorAction Stop | Out-Null
    $alvo = Join-Path $dirTeste 'arquivo-original.txt'
    $atalho = Join-Path $dirTeste 'arquivo-link.txt'
    Set-Content -LiteralPath $alvo -Value 'ok' -Encoding ASCII -ErrorAction Stop
    New-Item -ItemType SymbolicLink -Path $atalho -Target $alvo -ErrorAction Stop | Out-Null
    return [bool](Test-Path -LiteralPath $atalho)
  } catch {
    return $false
  } finally {
    if (Test-Path -LiteralPath $dirTeste) {
      Remove-Item -LiteralPath $dirTeste -Force -Recurse -ErrorAction SilentlyContinue
    }
  }
}

function Garantir-SuporteSymlinks {
  if (Testar-Symlinks) {
    Write-Host 'Permissao para links simbolicos (symlinks): OK.' -ForegroundColor Green
    return
  }
  Write-Host ''
  Write-Host 'O Windows bloqueou a criacao de links simbolicos exigidos pelos plugins Flutter.' -ForegroundColor Yellow
  Write-Host 'Abra Configuracoes e ative: Modo de Desenvolvedor.' -ForegroundColor Yellow
  Write-Host 'No Windows 11 recente: Configuracoes > Sistema > Avancado > Para desenvolvedores.'
  Write-Host 'Esta configuracao requer autorizacao do Windows; o instalador NAO a altera sozinho.'
  Write-Host 'Se o dispositivo for corporativo, solicite autorizacao a sua equipe de TI.'
  $resposta = Read-Host 'Pressione ENTER para abrir as Configuracoes (ou digite S para sair)'
  if ($resposta -match '^(?i:s|sair|cancelar)$') { Interromper 'Ativacao cancelada pelo usuario.' }
  try { Start-Process 'ms-settings:developers' -ErrorAction Stop }
  catch { Write-Warning 'Nao foi possivel abrir automaticamente as Configuracoes. Abra Configuracoes e pesquise Modo de Desenvolvedor.' }
  while ($true) {
    $resposta = Read-Host 'Depois de ativar o Modo de Desenvolvedor, pressione ENTER para testar novamente (ou S para sair)'
    if ($resposta -match '^(?i:s|sair|cancelar)$') { Interromper 'Ativacao cancelada pelo usuario.' }
    if (Testar-Symlinks) {
      Write-Host 'Links simbolicos liberados. Continuando a configuracao!' -ForegroundColor Green
      break
    }
    Write-Host 'Ainda sem permissao para criar links simbolicos. Verifique a configuracao do Windows.' -ForegroundColor Yellow
  }
}

function Instalar-WinGet([string]$Id) {
  $winget = Comando 'winget.exe'
  if (-not $winget) {
    Interromper "WinGet nao encontrado. Instale/atualize o 'Instalador de Aplicativo' da Microsoft Store, ou instale Git e Node.js manualmente. Depois rode este arquivo de novo."
  }
  Write-Host "Instalando $Id com WinGet (o Windows pode pedir permissao)..." -ForegroundColor Yellow
  Executar $winget @('install', '--id', $Id, '--exact', '--source', 'winget', '--accept-package-agreements', '--accept-source-agreements')
  Atualizar-Path
}

try {
  $projeto = $PSScriptRoot
  Set-Location -LiteralPath $projeto
  if (-not (Test-Path -LiteralPath (Join-Path $projeto 'pubspec.yaml'))) {
    Interromper 'Execute o arquivo CONFIGURAR-FIREBASE.cmd dentro da pasta principal do aplicativo (a mesma do pubspec.yaml).'
  }

  Write-Host 'CONFIGURACAO AUTOMATIZADA - FLUTTER + FIREBASE' -ForegroundColor Green
  Write-Host "Pasta do aplicativo: $projeto"
  Write-Host 'O script usa Git, Flutter, Node.js e Firebase CLI oficiais.'
  Write-Host 'Pode haver janelas de autorizacao do Windows e de login Google.'
  Write-Host 'Nao sera feita publicacao (deploy) nem criado servidor local.'
  Atualizar-Path

  Aviso '1/7 - Verificando Git'
  $git = Comando 'git.exe'
  if (-not $git) {
    Instalar-WinGet 'Git.Git'
    $git = Comando 'git.exe'
    if (-not $git) { Interromper 'Git nao encontrado apos instalacao. Feche o terminal, reabra e execute o instalador novamente.' }
  }
  Executar $git @('--version')

  Aviso '2/7 - Verificando Flutter SDK (inclui Dart)'
  $flutter = Comando 'flutter.bat'
  if (-not $flutter) {
    $sdkBase = Join-Path $env:LOCALAPPDATA 'Programs'
    $sdk = Join-Path $sdkBase 'flutter'
    $sdkExecutavel = Join-Path $sdk 'bin\flutter.bat'
    if (-not (Test-Path -LiteralPath $sdkExecutavel)) {
      if (Test-Path -LiteralPath $sdk) {
        Interromper "Existe uma instalacao Flutter incompleta em '$sdk'. Revise essa pasta antes de continuar. Nao sera apagada automaticamente."
      }
      New-Item -ItemType Directory -Force -Path $sdkBase | Out-Null
      Write-Host "Baixando Flutter (canal stable) para $sdk ..." -ForegroundColor Yellow
      Executar $git @('clone', '--depth', '1', '--branch', 'stable', 'https://github.com/flutter/flutter.git', $sdk)
    }
    Adicionar-PathUsuario (Join-Path $sdk 'bin')
    $flutter = Comando 'flutter.bat'
  }
  if (-not $flutter) { Interromper 'Flutter nao encontrado. Verifique o SDK e PATH.' }
  Executar $flutter @('--version')
  $dart = Comando 'dart.bat'
  if (-not $dart) { Interromper 'Dart nao encontrado apos preparar Flutter. Feche e reabra o instalador.' }

  Aviso '3/7 - Verificando Node.js e npm'
  $node = Comando 'node.exe'
  if (-not $node) {
    Instalar-WinGet 'OpenJS.NodeJS.LTS'
    $node = Comando 'node.exe'
  }
  if (-not $node) { Interromper 'Node.js nao encontrado apos instalacao. Reinicie o terminal e execute novamente.' }
  Executar $node @('--version')
  $npm = Comando 'npm.cmd'
  if (-not $npm) { Interromper 'npm.cmd nao encontrado. Reinstale ou repare o Node.js.' }

  Aviso '4/7 - Instalando Firebase CLI e FlutterFire CLI'
  Executar $npm @('install','--global','firebase-tools')
  Adicionar-PathUsuario (Join-Path $env:APPDATA 'npm')
  $firebase = Comando 'firebase.cmd'
  if (-not $firebase) { Interromper 'firebase.cmd nao encontrado apos npm install -g firebase-tools.' }
  Executar $firebase @('--version')
  Executar $dart @('pub','global','activate','flutterfire_cli')
  Adicionar-PathUsuario (Join-Path $env:LOCALAPPDATA 'Pub\Cache\bin')
  $flutterfire = Comando 'flutterfire.bat'
  if (-not $flutterfire) { Interromper 'flutterfire.bat nao encontrado apos instalacao. Verifique o PATH.' }
  Executar $flutterfire @('--version')

  Aviso '5/7 - Autorizando sua conta Google no Firebase'
  Write-Host 'O navegador pode abrir para voce autorizar o acesso ao SEU projeto.' -ForegroundColor Yellow
  Executar $firebase @('login')
  Write-Host "Verifique se o ID 'aplicativo-flutter-main' aparece:" -ForegroundColor Yellow
  Executar $firebase @('projects:list')

  Aviso '6/7 - Vinculando o projeto Flutter (Android e Web)'
  Garantir-SuporteSymlinks
  Executar $flutter @('pub','get')
  Executar $flutterfire @('configure','--project=aplicativo-flutter-main','--platforms=android,web')
  $firebaseOptions = Join-Path $projeto 'lib\firebase_options.dart'
  if (-not (Test-Path -LiteralPath $firebaseOptions)) {
    Interromper 'A configuracao terminou sem criar lib/firebase_options.dart. Verifique as mensagens acima.'
  }

  Aviso '7/7 - Analisando e preparando o aplicativo'
  Write-Host 'flutter doctor pode alertar sobre Android SDK. Para testar no Chrome, Android Studio nao e necessario.'
  Executar $flutter @('doctor') -PermitirErro
  Executar $flutter @('analyze') -PermitirErro
  $codigoAnalise = $script:UltimoCodigo
  Executar $flutter @('test') -PermitirErro
  $codigoTestes = $script:UltimoCodigo
  $codigoBuild = 0
  if (-not $PularBuildWeb) {
    Executar $flutter @('build','web') -PermitirErro
    $codigoBuild = $script:UltimoCodigo
  }

  # Exportacao enxuta: sem Swift Package gerado, arquivos temporarios e links simbolicos.
  # Executa em processo separado, para nao interferir com os comandos do Flutter.
  $exportador = Join-Path $projeto 'FINALIZAR-COMPARTILHAMENTO.ps1'
  if (-not (Test-Path -LiteralPath $exportador)) {
    Interromper 'FINALIZAR-COMPARTILHAMENTO.ps1 nao encontrado.'
  }
  $powershell = Join-Path $PSHOME 'powershell.exe'
  Executar $powershell @('-NoProfile','-ExecutionPolicy','Bypass','-File',$exportador)
  $destino = Join-Path (Split-Path -Parent $projeto) 'Aplicativo-Flutter-main-Firebase-CONFIGURADO.zip'

  Write-Host "`nCONFIGURACAO CONCLUIDA" -ForegroundColor Green
  Write-Host "Arquivo para compartilhar: $destino" -ForegroundColor Green
  Write-Host 'Ao compartilhar, mantenha lib/firebase_options.dart e as demais configuracoes de plataforma.'
  Write-Host 'O Firebase Authentication segue funcionando na nuvem, sem seu computador ligado.'
  if ($codigoAnalise -ne 0 -or $codigoTestes -ne 0 -or $codigoBuild -ne 0) {
    Write-Warning "Ha validacoes pendentes: analyze=$codigoAnalise / test=$codigoTestes / build-web=$codigoBuild. Revise os erros exibidos."
  } else {
    Write-Host 'flutter analyze/test/build web: comandos concluídos sem erro de processo.' -ForegroundColor Green
  }
  Write-Host 'Para abrir no Chrome em modo desenvolvimento, execute: flutter run -d chrome'
} catch {
  Write-Host "`nERRO: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host 'Corrija o problema descrito e execute o instalador novamente. Etapas instaladas nao serao apagadas.' -ForegroundColor Yellow
  exit 1
}
