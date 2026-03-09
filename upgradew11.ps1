$iso_origen = "\\server\almacen\isos\Windows_11_25H2_Spanish_x64.iso"
$iso_file = "C:\temp\Windows_11_25H2_Spanish_x64.iso"

# Crear la carpeta de destino si no existe
if (!(Test-Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}
# Copiar el archivo
Copy-Item -Path $iso_origen -Destination $iso_file -Force

Mount-DiskImage -ImagePath $iso_file
$drive = (Get-DiskImage -ImagePath $iso_file | Get-Volume).DriveLetter
$path = "$drive`:\setup.exe"
write-host $path
Start-Process -FilePath $path -ArgumentList "/Auto Upgrade /compat ignorewarning /dynamicupdate disable /eula accept /quiet" -Wait

$iso_file = "C:\temp\Windows_11_25H2_Spanish_x64.iso"
Dismount-DiskImage -ImagePath $iso_file -ErrorAction SilentlyContinue
Remove-Item -Path $iso_file -Force -ErrorAction SilentlyContinue