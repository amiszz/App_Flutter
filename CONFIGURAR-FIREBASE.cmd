@echo off
setlocal
cd /d "%~dp0"
echo ==========================================
echo  Flutter + Firebase - configuracao assistida
 echo ==========================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CONFIGURAR-FIREBASE.ps1"
set "exitcode=%ERRORLEVEL%"
echo.
if not "%exitcode%"=="0" (
    echo A configuracao terminou com erro. Leia a mensagem acima.
) else (
    echo A configuracao terminou. Revise as validacoes acima.
)
echo.
pause
exit /b %exitcode%
