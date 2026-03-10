# Write-Host "2º paso, Instalar openVPN y crear usuario vpnportatil"
#####################################################################
if ($env:COMPUTERNAME -like "PT*" -or $NuevoNombre -like "PT*") {
	$ruta = (Get-Location).Path
	# Write-Host "Instalar openvpn 2.XXX"
	# Detenemos procesos relacionados con OpenVPN
	Stop-Process -Name "openvpnserv" -ErrorAction SilentlyContinue -Force
	Stop-Process -Name "openvpnserv2" -ErrorAction SilentlyContinue -Force
	Stop-Process -Name "openvpn-gui" -ErrorAction SilentlyContinue -Force
	# Detenemos servicios de OpenVPN
	Stop-Service -Name "OpenVPNService" -Force -ErrorAction Continue
	Stop-Service -Name "OpenVPNServiceInteractive" -Force -ErrorAction Continue
	Set-Service -Name "OpenVPNServiceInteractive" -StartupType Manual
	# Desinstalamos versiones antiguas de OpenVPN
	if (Test-Path "C:\Program Files\OpenVPN\Uninstall.exe") { Start-Process -FilePath "C:\Program Files\OpenVPN\Uninstall.exe" -ArgumentList "/S /qn" -Wait }
	Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /X{F69213F0-C729-C1BC-6234-7B824B6A4267}" -Wait
	Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /X{4AE6DC13-60F2-4D60-BD4A-7AE8E64834D7}" -Wait
	Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /X{F3CB40E9-AC2B-4AEE-B644-847049D29035}" -Wait
	# Eliminamos servicios residuales
	sc delete OpenVPNServiceInteractive
	sc delete OpenVPNService
	Start-Sleep -Seconds 20
	# Instalamos OpenVPN
	# OPENVPN 2.4: %RUTA%\ejecutables\openvpn-install-2.4.12-I601-Win10.exe /S /SELECT_SHORTCUTS=0 /SELECT_ASSOCIATIONS=0 /SELECT_LAUNCH=0 /SELECT_OPENVPN=1 /SELECT_SERVICE=1 /SELECT_TAP=1
	$openvpn_msi = join-path $ruta 'OpenVPN-2.5.10-I601-amd64.msi'
	Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $openvpn_msi ALLUSERS=1 /qn /norestart /log output.log ADDLOCAL=OpenVPN.Service,OpenVPN,Drivers,Drivers.Wintun,Drivers.TAPWindows6 /passive" -Wait
	# para GUI y que se abra al arrancar:
	# Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $openvpn_msi ALLUSERS=1 /qn /norestart /log output.log ADDLOCAL=OpenVPN.GUI,OpenVPN.GUI.OnLogon /passive" -Wait
	# elimina iconos del escritorio y otros vestigios de la instalacion
	Remove-Item -Path "$env:PUBLIC\Desktop\OpenVPN GUI.lnk" -Force -ErrorAction Continue
	Remove-Item -Path "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\TAP-Windows" -Recurse -Force -ErrorAction Continue
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\OpenVPN_UserSetup" -Name "StubPath" -Force -ErrorAction Continue
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OPENVPN-GUI" -Force -ErrorAction Continue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OPENVPN-GUI" -Force -ErrorAction Continue
	# Copiamos los ficheros necesarios para openVPN y hacemos q los usuarios sin privilegios no puedan verlos
	$zipPath = join-path $ruta datos_vpn.zip
	$authFile = 'auth\$NuevoNombre.txt'
	$authDestino = '$env:PROGRAMFILES\OpenVPN\config-auto\auth.txt'
	$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
	try {
		$entry = $zip.Entries | Where-Object { $_.FullName -eq $authFile -or $_.FullName -eq ($authFile -replace '\\','/') }
		$entry.ExtractToFile($authDestino, $true)
	} finally { $zip.Dispose() }
	$boeuser = "boe" + NuevoNombre.Substring(2)
	$ovpnFile = 'ovpn\$NuevoNombre.txt'
	$ovpnDestino = '$env:PROGRAMFILES\OpenVPN\config-auto\auth.txt'
	$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
	try {
		$entry = $zip.Entries | Where-Object { $_.FullName -eq $ovpnFile -or $_.FullName -eq ($ovpnFile -replace '\\','/') }
		$entry.ExtractToFile($ovpnDestino, $true)
	} finally { $zip.Dispose() }
	iCACLS "$env:ProgramFiles\OpenVPN\config-auto" /inheritance:d
	iCACLS "$env:ProgramFiles\OpenVPN\config-auto" /remove:g "Usuarios"
	Stop-Service -Name "OpenVPNServiceInteractive" -Force -ErrorAction Continue
	Set-Service -Name "OpenVPNServiceInteractive" -StartupType Manual
	Set-Service -Name "OpenVPNService" -StartupType Automatic
	Start-Service -Name "OpenVPNService" -ErrorAction Continue
	Write-Host "3er paso, Crear usuario vpnportatil"
	$keyvpnportatil = 'vpnportatil\vpn_$NuevoNombre.txt'
	Add-Type -AssemblyName System.IO.Compression.FileSystem
	$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
	try {
		$entry = $zip.Entries | Where-Object { $_.FullName -ieq $keyvpnportatil }
        $reader = New-Object System.IO.StreamReader($entry.Open())
        $vpnpass = $reader.ReadToEnd()
        $reader.Close()
	} finally { $zip.Dispose() }
	$Securevpnpass = ConvertTo-SecureString $vpnpass -AsPlainText -Force
	if (-not (Get-LocalUser -Name "vpnportatil" -ErrorAction Continue)) { New-LocalUser -Name "vpnportatil" -Password $Securevpnpass }
	Add-LocalGroupMember -Group "Administradores" -Member "vpnportatil" -ErrorAction Continue
	Set-LocalUser -Name "vpnportatil" -PasswordNeverExpires $true
	New-ItemProperty -Path $UserListRegPath -Name "vpnportatil" -PropertyType DWord -Value 0 -Force | Out-Null
	# Write-Host "Eliminar el resto de usuarios"
	Write-Host "Eliminar el resto de usuarios"
	$Keep = @('adminlocal','portatil','Administrator','Administrador','DefaultAccount','Guest','WDAGUtilityAccount')
	$Keep +=  [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[-1]
	$usersToRemove = Get-LocalUser | Where-Object { -not ($Keep -contains $_.Name) }
	$ProfilesPathRoot = 'C:\Users'
	foreach ($u in $usersToRemove) {
		$username = $u.Name
		Disable-LocalUser -Name $username -ErrorAction Continue
		Remove-LocalUser -Name $username -ErrorAction Continue
		$profilePath = Join-Path $ProfilesPathRoot $username
		$cimProfiles = Get-CimInstance -ClassName Win32_UserProfile -ErrorAction Continue | Where-Object { $_.LocalPath -and ($_.LocalPath.TrimEnd('\') -ieq $profilePath.TrimEnd('\')) }
		if ($cimProfiles) {
			foreach ($p in $cimProfiles) {
				$result = $p.Delete()
				Remove-Item -LiteralPath $profilePath -Recurse -Force -ErrorAction Continue
			}
		}
	}
	# Write-Host "Add/remove programs 'VPN fase 3 versión 1.1'"
	Write-Host "Add/remove programs 'VPN fase 3 versión 1.1'"
	if (-not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VPN fase3")) {New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VPN fase3" -Force | Out-Null}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VPN fase3" -Name "DisplayName" -PropertyType String -Value "VPN fase3" -Force | Out-Null
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VPN fase3" -Name "DisplayVersion" -PropertyType String -Value "1.1" -Force | Out-Null
	<#
	opciones del msi:
	/i           - the installer file
	/passive     - run as silent
	ADDLOCAL=    - choose what to install, including:
				- OpenVPN.Service
				- OpenVPN
				- OpenVPN.GUI
				- OpenVPN.GUI.OnLogon
				- Drivers
				- Drivers.Wintun
				- Drivers.TAPWindows6
	PRODUCTDIR=  - target directory
	#>
	<#
	### OLD OPENVPN 2.4: 
	# Copiamos los ficheros necesarios para openVPN y hacemos q los usuarios sin privilegios no puedan verlos
	copy %RUTA%\auth\%NUEVONOMBRE%.txt "%PROGRAMFILES%\openvpn\config\auth.txt"
	set /p BOEUSER=<"%PROGRAMFILES%\openvpn\config\auth.txt"
	# copia el fichero ovpn tanto tipo ptxxxx como boexxxx
	copy %RUTA%\ovpn\%BOEUSER%.ovpn "%PROGRAMFILES%\openvpn\config\boe.ovpn"
	copy %RUTA%\ovpn\%NUEVONOMBRE%.ovpn "%PROGRAMFILES%\openvpn\config\boe.ovpn"
	iCACLS "%PROGRAMFILES%\openvpn\config" /inheritance:d
	iCACLS "%PROGRAMFILES%\openvpn\config" /remove:g "Usuarios"
	### ACTUALIZA DE OPENVPN 2.4 a 2.5/2.6
	# mueve los datos de config a config-auto y los protege
	copy /Y "%PROGRAMFILES%\openvpn\config\*.*" "%PROGRAMFILES%\openvpn\config-auto\*.*"
	iCACLS "%PROGRAMFILES%\openvpn\config-auto" /inheritance:d
	iCACLS "%PROGRAMFILES%\openvpn\config-auto" /remove:g "Usuarios"
	del /s /f /q "%PROGRAMFILES%\openvpn\config"
	rmdir /s /q "%PROGRAMFILES%\openvpn\config"
	# Reinicia OpenVPNService
	sc stop OpenVPNService
	sc stop OpenVPNServiceInteractive
	sc config OpenVPNServiceInteractive start= demand
	sc config OpenVPNService start= auto
	sc start OpenVPNService
	#>
}
