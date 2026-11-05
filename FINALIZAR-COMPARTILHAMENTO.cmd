@echo off
setlocal
cd /d "%~dp0"
echo.
echo FINALIZAR EXPORTACAO - APLICATIVO FLUTTER + FIREBASE
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0FINALIZAR-COMPARTILHAMENTO.ps1"
set "CODIGO=%ERRORLEVEL%"
echo.
if not "%CODIGO%"=="0" (
  echo Exportacao nao concluida. Confira a mensagem de erro acima.
) else (
  echo O ZIP final esta na pasta acima desta pasta de projeto.
)
pause
exit /b %CODIGO%
