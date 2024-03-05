:: ================================================================================== 
:: NOMBRE: Limpieza de Disco 
:: AUTOR: Lucas Gomez
:: VERSION: 6
:: ================================================================================== 
@echo off

color 0C
title Verificando permisos de administrador...

setlocal enableextensions enabledelayedexpansion > nul 2> nul
cd /d "%~dp0" > nul 2> nul

goto Permisos 

:: Verificando los permisos de administrador.

: Permisos
openfiles>nul 2>&1
 
if %errorlevel% EQU 0 goto Limpieza
 
echo. =========================================================================
echo.
echo.    No se tienen permisos para ejecutar esta herramienta.
echo.    Esta herramienta no funciona sin permisos de administrador.
echo.
echo.    Es necesario ejecutar esta herramienta con permisos de administrador.
echo.
echo. =========================================================================
echo.
echo.Presione una tecla para cerrar la ventana . . .
echo.
pause>nul
goto :Eof


:Limpieza

color 0A
title Realizando limpieza...
@echo off


:: Eliminar huerfanos.

echo Eliminando archivos huerfanos de Windows installer...

set DELETE_ORPHANS=1
        if /i "%DELETE_ORPHANS%" equ "1" goto :Work

:Work
    set FOUND="not_orphaned.txt"
    if exist %FOUND% del %FOUND%

    set NOT_FOUND="orphaned.txt"
    if exist %NOT_FOUND% del %NOT_FOUND%

    set INSTALLER_DATA="installer_data.txt"
    if exist %INSTALLER_DATA% del %INSTALLER_DATA%

    echo Buscando archivos de instalacion registrados...
    REM Va a buscar los archivos .msi y .msp
    REM El comando findstr hara que el archivo sea mas ligero si se lo busca luego.
    for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData" /t REG_SZ /s /v "LocalPackage" ^| findstr /i LocalPackage') do (
       
        echo %%a >>%INSTALLER_DATA%
    )

    echo Buscando referencias para detectar archivos del installer...
    for /f "delims=" %%a in ('dir /b /s %WINDIR%\Installer\*.msi %WINDIR%\Installer\*.msp') do (
        findstr /c:"%%a" %INSTALLER_DATA% > nul 2> nul
        if !errorlevel!==1 (
            if /i "%DELETE_ORPHANS%" equ "1" (                
                del "%%a" > nul 2> nul
            ) else (
                echo "%%a" NOT FOUND >>%NOT_FOUND% > nul 2> nul
            )
        )
    )

    del %INSTALLER_DATA%


:: Limpiando carpetas de temporales y similares.

echo Limpiando archivos temporales...

@echo off
powershell -Command "Remove-Item '%windir%\Temp\*' -Recurse -Force" > nul 2> nul 
@echo off
powershell -Command "Remove-Item '%windir%\SoftwareDistribution\*' -Recurse -Force" > nul 2> nul
@echo off
powershell -Command "Remove-Item '%windir%\Prefetch\*' -Recurse -Force" > nul 2> nul 
@echo off
powershell -Command "Remove-Item '%windir%\Logs\CBS\*' -Recurse -Force" > nul 2> nul
@echo off
powershell -Command "Remove-Item '%windir%\*.bak' -Recurse -Force" > nul 2> nul

@echo off
powershell -Command "Remove-Item 'C:\Users\*\AppData\Local\Temp\*' -Recurse -Force" > nul 2> nul

@echo off
powershell -Command "Remove-Item '%systemdrive%\*.tmp' -Recurse -Force" > nul 2> nul
@echo off
powershell -Command "Remove-Item '%systemdrive%\*.log' -Recurse -Force" > nul 2> nul
@echo off
powershell -Command "Remove-Item '%systemdrive%\*._mp' -Recurse -Force" > nul 2> nul
@echo off
powershell -Command "Remove-Item '%systemdrive%\*.gid' -Recurse -Force" > nul 2> nul
@echo off
powershell -Command "Remove-Item %systemdrive%\*.chk' -Recurse -Force" > nul 2> nul
@echo off
powershell -Command "Remove-Item '%systemdrive%\*.chk' -Recurse -Force" > nul 2> nul

echo Creando claves de registro para Clean Manager....

@echo off

@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos temporales .tmp creados en instalacion de programas.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos descargados para instalacion de programas.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos temporales de internet almacenados en el disco duro.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos de desecho creados por Windows de extension .dmp
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina paginas descargadas para verlas offline sin conexion.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina carpetas con formato FOUND.XXX que contienen clustres perdidos despues de realizar una reparacion de disco con CHKDSK.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina residuos de instalaciones anteriores de Windows.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos de la Papelera de reciclaje.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina logs o archivos de registro almacenados en la carpeta Windows.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos .dmp con informacion de errores ocurridos en Windows.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos .dmp con informacion de errores de pantalla azul almacenados en la carpeta Windows\Minidump
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos temporales encontrados en la carpeta %TEMP%
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos temporales creados por instalador de Windows.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Se elimina la cache de vistas en miniaturas.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos desechados de actualizaciones de Windows.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos de reportes de error del usuario actual.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos de reportes de error del usuario actual pendientes.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos de reportes de error de todos los usuarios.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos de reportes de error pendientes de todos los usuarios. 
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -force -ea SilentlyContinue;" > nul 2> nul

:: Elimina archivos logs y registros de actualizaciones.
@echo off
powershell -Command "if((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files') -ne $true) {  New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -force -ea SilentlyContinue;" > nul 2> nul

echo Configurando claves de Clean Manager...

@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul
@echo off
powershell -Command "New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -Name 'StateFlags0064' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;" > nul 2> nul

echo Ejecutando Clean Manager

cleanmgr /sagerun:64  > nul 2> nul

@echo off

setlocal enabledelayedexpansion  > nul 2> nul

:: BARRA DE PROGRESO 

for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"
for /f %%a in ('"prompt $H&for %%b in (0) do rem"') do set "BS=%%a"

<nul set /p"=!BS!!CR![]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![.]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![..]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![...]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![....]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![.....]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![......]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![.......]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![........]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![.........]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![..........]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![...........]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![............]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![.............]" & Timeout /t 1 >nul
<nul set /p"=!BS!!CR![..............]" & Timeout /t 1 >nul

:: Aviso de finalizacion

@echo off
powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('Limpieza finalizada. Click en "Aceptar" para cerrar esta ventana.','LIMPIEZA FINALIZADA.','OK','Information')
