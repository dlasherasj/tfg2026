Write-Host "Removing OneDrive"

# First make our registry tweaks. To do this, we need the default user's hive loaded
reg load HKU\default c:\users\default\ntuser.dat

# Now, before importing changes, look for the OneDrive Personal installer location (we'll need it later) 
#  Also, KHU isn't available by default, so check that, too
if ((Get-PSDrive -PSProvider Registry).Name -notcontains 'HKU') {
    New-PSDrive HKU Registry HKEY_USERS | Out-Null
    $removeHKU = $true
}
$odp = (Get-ItemProperty -path 'HKU:\default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run').OneDriveSetup
if ($removeHKU) {
    Remove-PSDrive -Name "HKU"
}

# Import our registry changes
# This removes the command to install OneDrive again from the default user template
reg import .\DefaultRegistryFixes.reg
reg unload HKU\default
# Done with registry

# Make sure OneDrive isn't later changed to be a Windows Store app
Get-AppxPackage -AllUsers "*OneDrive*" | Remove-AppxPackage -AllUsers

# OneDrive is installed in one or more of five possible locations:
# Windows\System, Windows\System32, Windows\SysWOW64, Program Files, and Program Files (x86)
# Need to check all five

# First, the Windows locations
if (Test-Path "C:\Windows\System\OneDriveSetup.exe") {
    start -wait -filepath "C:\Windows\System\OneDriveSetup.exe" -argumentlist "/uninstall","/qn"
}
if (Test-Path "C:\Windows\System32\OneDriveSetup.exe") {
    start -wait -filepath "C:\Windows\System32\OneDriveSetup.exe" -argumentlist "/uninstall","/qn"
}
if (Test-Path "C:\Windows\SysWOW64\OneDriveSetup.exe") {
    start -wait -filepath "C:\Windows\SysWOW64\OneDriveSetup.exe" -argumentlist "/uninstall","/qn"
}

# Then Program Files. 
# These locations also have a version number subfolder that may change over time
# So we need extra steps to find that folder
if (Test-path "C:\Program Files\Microsoft OneDrive") {
    $folder = (get-childitem "C:\Program Files\Microsoft OneDrive").Name | ?{ $_ -match "^\d{2}.*" }
    # can be several folders. Only one will have the uninstaller
    $folder | % {
        if (Test-Path "C:\Program Files\Microsoft OneDrive\$_\OneDriveSetup.exe") {
            $path = "C:\Program Files\Microsoft OneDrive\$_\OneDriveSetup.exe"
            start -wait -filepath $path -argumentlist "/uninstall","/qn"
        }
    }
}
if (Test-path "C:\Program Files (x86)\Microsoft OneDrive") {
    $folder = (get-childitem "C:\Program Files (x86)\Microsoft OneDrive").Name | ?{ $_ -match "^\d{2}.*" }
    # can be several folders. Only one will have the uninstaller
    $folder | % {
        if (Test-Path "C:\Program Files (x86)\Microsoft OneDrive\$_\OneDriveSetup.exe") {
            $path = "C:\Program Files (x86)\Microsoft OneDrive\$_\OneDriveSetup.exe"
            start -wait -filepath $path -argumentlist "/uninstall","/qn"
        }
    }
}

# Now look in WinSXS for the setup file backup
$ods = get-childitem "C:\Windows\WinSxS\amd64_microsoft-windows-onedrive-setup*"
if ($ods) {
    $path = "C:\Windows\WinSxS\$($ods.Name)\*.*"
    # Don't need to uninstall. Just remove the files. But also need to take ownership first
    takeown /F $path /A | Out-Null
    icacls $path /grant Administrators:M | Out-Null
    remove-item -path $path -force | out-null
}

#   And finally clean up installer program found earlier in the registry
if ($odp)
{
    $odp = $odp.Replace(" /thfirstsetup", "") # remove command line argument
    takeown /F $odp /A | Out-Null
    icacls $odp /grant Administrators:M | Out-Null
    remove-item $odp | out-null
}