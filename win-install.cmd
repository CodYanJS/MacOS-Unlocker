@echo off
setlocal ENABLEEXTENSIONS
echo.
echo copy de Unlocker 3.0.2 pour installer macos sur VMware Workstation ou Player
echo =====================================
echo (c) Dave Parsons 2011-18
echo.
echo Set encoding parameters...
chcp 850

net session >NUL 2>&1
if %errorlevel% neq 0 (
    echo Attention, Lancez le en Administrateur
    exit /b
)
pause
echo.
set KeyName="HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Player"
:: delims is a TAB followed by a space
for /F "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v InstallPath') do set InstallPath=%%B
echo VMWare est installé a cette endroit: %InstallPath%
for /F "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v ProductVersion') do set ProductVersion=%%B
echo Version de VMware: %ProductVersion%

pushd %~dp0

echo.
echo Arret des Services VMWare...
net stop vmware-view-usbd > NUL 2>&1
net stop VMwareHostd > NUL 2>&1
net stop VMAuthdService > NUL 2>&1
net stop VMUSBArbService > NUL 2>&1
taskkill /F /IM vmware-tray.exe > NUL 2>&1

echo.
echo Sauvegarde des fichiers...
rd /s /q .\backup > NUL 2>&1
mkdir .\backup
mkdir .\backup\x64
xcopy /F /Y "%InstallPath%x64\vmware-vmx.exe" .\backup\x64
xcopy /F /Y "%InstallPath%x64\vmware-vmx-debug.exe" .\backup\x64
xcopy /F /Y "%InstallPath%x64\vmware-vmx-stats.exe" .\backup\x64
xcopy /F /Y "%InstallPath%vmwarebase.dll" .\backup\

echo.
echo Patch en cours...
unlocker.exe

echo.
echo Installation des outils VMWare...
gettools.exe
xcopy /F /Y .\tools\darwin*.* "%InstallPath%"

echo.
echo Démarrage des services VMWare...
net start VMUSBArbService > NUL 2>&1
net start VMAuthdService > NUL 2>&1
net start VMwareHostd > NUL 2>&1
net start vmware-view-usbd > NUL 2>&1

popd
echo.
echo Terminé!
