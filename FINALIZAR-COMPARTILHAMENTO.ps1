#Requires -Version 5.1
<#
  Exporta o aplicativo Flutter ja configurado para um ZIP compartilhavel.
  Nao instala software, nao faz login, nao altera as configuracoes Firebase,
  e nao inclui arquivos gerados para iOS/macOS ou links simbolicos.
#>
$ErrorActionPreference = 'Stop'

try {
  $projeto = $PSScriptRoot
  $nomeProjeto = 'Aplicativo-Flutter-main'
  $pubspec = Join-Path $projeto 'pubspec.yaml'
  $firebaseOptions = Join-Path $projeto 'lib\firebase_options.dart'
  $principal = Join-Path $projeto 'lib\main.dart'
  if (-not (Test-Path -LiteralPath $pubspec -PathType Leaf)) {
    throw 'Execute este arquivo na pasta principal do projeto Flutter (onde esta pubspec.yaml).'
  }
  if (-not (Test-Path -LiteralPath $principal -PathType Leaf)) {
    throw 'O arquivo lib/main.dart nao foi localizado.'
  }
  if (-not (Test-Path -LiteralPath $firebaseOptions -PathType Leaf)) {
    throw 'Falta lib/firebase_options.dart. A configuracao com flutterfire configure ainda nao esta concluida.'
  }

  # Nenhuma pasta de cache ou artefato temporario deve ser enviada ao destinatario.
  # Em especial, ios/Flutter/ephemeral e macos/Flutter/ephemeral contem
  # FlutterGeneratedPluginSwiftPackage, que pode conter links simbolicos invalidos no Windows.
  $pastasIgnoradas = @(
    '.git', '.dart_tool', 'build', '.gradle', '.firebase', 'node_modules',
    'Pods', '.symlinks', 'ephemeral', '.plugin_symlinks', '.swiftpm',
    'DerivedData', '.idea', '.vscode', '.pub-cache'
  )
  $arquivosIgnorados = @(
    '*.log', '*.jks', '*.keystore', '*.p12', '*.p8', '*.pem', '*.key',
    '*.mobileprovision', 'local.properties', '.env', '.env.*',
    'serviceAccountKey.json', '*-firebase-adminsdk-*.json',
    'id_rsa', 'id_ed25519', '*.tmp', '*.bak'
  )
  $destino = Join-Path (Split-Path -Parent $projeto) ($nomeProjeto + '-Firebase-CONFIGURADO.zip')
  $temporario = Join-Path (Split-Path -Parent $projeto) ($nomeProjeto + '-export-' + [guid]::NewGuid().ToString('N') + '.tmp.zip')
  $script:totalArquivos = 0
  $script:totalIgnorados = 0
  Add-Type -AssemblyName System.IO.Compression
  Add-Type -AssemblyName System.IO.Compression.FileSystem

  function Adicionar-PastaZip([string]$Pasta, [string]$Relativo) {
    foreach ($item in (Get-ChildItem -LiteralPath $Pasta -Force -ErrorAction Stop)) {
      # Nao seguir junctions, symlinks, ou outros pontos de nova analise do NTFS.
      if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        $script:totalIgnorados++
        continue
      }
      if ($item.PSIsContainer) {
        if ($pastasIgnoradas -contains $item.Name) {
          $script:totalIgnorados++
          continue
        }
        Adicionar-PastaZip -Pasta $item.FullName -Relativo ($Relativo + '/' + $item.Name)
        continue
      }
      $deveIgnorar = $false
      foreach ($padrao in $arquivosIgnorados) {
        if ($item.Name -like $padrao) {
          $deveIgnorar = $true
          break
        }
      }
      if ($deveIgnorar) {
        $script:totalIgnorados++
        continue
      }
      $nomeEntrada = $Relativo + '/' + $item.Name
      $entrada = $script:arquivoZip.CreateEntry($nomeEntrada, [System.IO.Compression.CompressionLevel]::Optimal)
      $origemStream = $null
      $destinoStream = $null
      try {
        $origemStream = [System.IO.File]::Open($item.FullName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $destinoStream = $entrada.Open()
        $origemStream.CopyTo($destinoStream)
        $script:totalArquivos++
      } finally {
        if ($destinoStream) { $destinoStream.Dispose() }
        if ($origemStream) { $origemStream.Dispose() }
      }
    }
  }

  Write-Host 'Preparando ZIP do projeto Flutter ja configurado...' -ForegroundColor Cyan
  $zipStream = $null
  $script:arquivoZip = $null
  try {
    $zipStream = [System.IO.File]::Open($temporario, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    $script:arquivoZip = [System.IO.Compression.ZipArchive]::new($zipStream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
    Adicionar-PastaZip -Pasta $projeto -Relativo $nomeProjeto
  } finally {
    if ($script:arquivoZip) { $script:arquivoZip.Dispose() }
    if ($zipStream) { $zipStream.Dispose() }
  }

  # Confere o arquivo comprimido antes de substituir uma exportacao anterior.
  $verificacao = [System.IO.Compression.ZipFile]::OpenRead($temporario)
  try {
    $nomes = @($verificacao.Entries | ForEach-Object { $_.FullName })
    foreach ($obrigatorio in @(
      "$nomeProjeto/pubspec.yaml", "$nomeProjeto/lib/main.dart",
      "$nomeProjeto/lib/firebase_options.dart"
    )) {
      if ($nomes -notcontains $obrigatorio) {
        throw "O ZIP nao contem o arquivo obrigatorio: $obrigatorio"
      }
    }
    if ($nomes | Where-Object { $_ -match '/(?:ephemeral|\.dart_tool|build|\.symlinks)/' }) {
      throw 'A exportacao incluiu indevidamente um diretorio gerado pelo Flutter.'
    }
  } finally {
    $verificacao.Dispose()
  }

  Move-Item -LiteralPath $temporario -Destination $destino -Force
  Write-Host ''
  Write-Host 'EXPORTACAO CONCLUIDA COM SUCESSO!' -ForegroundColor Green
  Write-Host "Arquivo criado: $destino" -ForegroundColor Green
  Write-Host "Arquivos incluidos: $script:totalArquivos | Itens ignorados: $script:totalIgnorados"
  Write-Host 'O ZIP inclui lib/firebase_options.dart e nao depende deste computador para autenticar usuarios.'
  Write-Host 'Nao inclui build/web. Para publicar a Web, use a pasta build/web gerada pelo Flutter.'
} catch {
  Write-Host "`nERRO AO EXPORTAR: $($_.Exception.Message)" -ForegroundColor Red
  if ($temporario -and (Test-Path -LiteralPath $temporario)) {
    Remove-Item -LiteralPath $temporario -Force -ErrorAction SilentlyContinue
  }
  exit 1
}
