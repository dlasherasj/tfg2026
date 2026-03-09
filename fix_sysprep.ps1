## si no funciona SYSPREP:
Get-AppxPackage -AllUsers *LanguageExperiencePackes* | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*LanguageExperiencePackes*" } | Remove-AppxProvisionedPackage -Online
Get-AppxPackage -AllUsers *notepadplusplus* | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*notepadplusplus*" } | Remove-AppxProvisionedPackage -Online