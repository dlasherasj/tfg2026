@ECHO off
powershell set-content -path "c:\temp\customize.cmd" -stream Zone.Identifier -Value "[zoneTransfer]`nZoneId=3"
ipconfig /registerdns
LABEL c: %COMPUTERNAME%
SET name=%COMPUTERNAME%
NET localgroup "Usuarios de escritorio remoto" BOE\%name:~4% /add
NET user administrador /active:no
LOGOFF
DEL c:\temp\customize.cmd /Q