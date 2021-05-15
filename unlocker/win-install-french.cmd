@echo off
setlocal ENABLEEXTENSIONS
echo .
echo  Unlocker 2.0.1 Pour installer MacOS sur VMWare a partir de la version 10
echo =====================================
echo (c) CodYanJS 2019-21
echo .
chcp 850

net session >NUL 2>&1
if %errorlevel% neq 0 (
    echo Erreur, Vous devez le lancer en mode Administrateur !
    echo Le système va maintenant s'éteindre. Exit Code -1.
    exit /b
)
pause
echo .
set KeyName="HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Player"
:: delims is a TAB followed by a space
for /F "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v InstallPath') do set InstallPath=%%B
echo VMWare est installé dans : %InstallPath%
for /F "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v ProductVersion') do set ProductVersion=%%B
echo Version de VMWare : %ProductVersion%

pushd %~dp0

echo .
echo Arrêt des servicesq  VMWare...
net stop vmware-view-usbd > NUL 2>&1
net stop VMwareHostd > NUL 2>&1
net stop VMAuthdService > NUL 2>&1
net stop VMUSBArbService > NUL 2>&1
taskkill /F /IM vmware-tray.exe > NUL 2>&1

echo .
echo Sauvegarde des fichiers ...
rd /s /q .\backup > NUL 2>&1
mkdir .\backup
mkdir .\backup\x64
xcopy /F /Y "%InstallPath%x64\vmware-vmx.exe" .\backup\x64
xcopy /F /Y "%InstallPath%x64\vmware-vmx-debug.exe" .\backup\x64
xcopy /F /Y "%InstallPath%x64\vmware-vmx-stats.exe" .\backup\x64
xcopy /F /Y "%InstallPath%vmwarebase.dll" .\backup\

echo .
echo Patch en cours ...
unlocker.exe

echo .
echo Installation des outils VMWare...
gettools.exe
xcopy /F /Y .\tools\darwin*.* "%InstallPath%"

echo .
echo Démarrage des Services VMWare...
net start VMUSBArbService > NUL 2>&1
net start VMAuthdService > NUL 2>&1
net start VMwareHostd > NUL 2>&1
net start vmware-view-usbd > NUL 2>&1

popd
echo.
echo Términés!
