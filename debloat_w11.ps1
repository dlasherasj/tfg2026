# Reglas del firewall xa conexión remota:
Write-Host "Reglas del firewall xa conexión remota"
Set-NetFirewallRule -DisplayGroup 'Compartir archivos e Impresoras' -Enabled True -Profile any -RemoteAddress 10.14.136.0/21,10.14.144.0/21
Set-NetFirewallRule -DisplayGroup 'Escritorio Remoto' -Enabled True -Profile any -RemoteAddress 10.14.136.0/21,10.14.144.0/21

# Ocultar usuarios importantes del login
$users = @(
    "vpnportatil",
    "adminlocal",
    "administrador",
    "adminboe",
    "adminpcs",
    "BOE\administrador",
    "BOE\adminboe",
    "BOE\adminpcs"
)
$regPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
foreach ($user in $users) {
    New-ItemProperty -Path $regPath -Name $user -PropertyType DWord -Value 0 -Force | Out-Null
    Write-Host "Usuario ocultado: $user"
}

# Importar certificado del Palo Alto para descifrado
$certPath = ".\PA.cer"
$storePath = "Cert:\LocalMachine\Root"
Import-Certificate -FilePath $certPath -CertStoreLocation $storePath
$certs = Get-ChildItem Cert:\LocalMachine\Root | Where-Object { $_.Subject -like "*PA*" }
if ($certs) { Write-Host "Certificado instalado" } else { Write-Host "Certificado no instalado" }

# ojo fix notepad q se abre C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini +SH
attrib +h +s "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini"

# Copia c:\temp\customize.cmd, que cambia etiqueta volumen, deshabilita usuario administrador local (vmware lo rehabilita al hacer el sysprep), agrega computername a usuarios de escritorio remoto, y se autoelimina
if (-not (Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory | Out-Null
}
Copy-Item ".\customize.cmd" -Destination "C:\Temp\customize.cmd" -Force

Write-Host "-- Important REGEDIT config"
#oculta icono de VMtools
if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
New-ItemProperty -Path "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools" -Name "ShowTray" -PropertyType DWord -Value 0 -Force

# Elimina sugerencias en búsqueda (está repetido mas abajo)
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -PropertyType DWord -Value 1 -Force

# Elimina icono de Edge en escritorio para usuarios nuevos
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "CreateDesktopShortcutDefault" -PropertyType DWord -Value 0 -Force

# Deshabilita log en caso de crash
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\CrashControl" -Name "EnableLogFile" -PropertyType DWord -Value 0 -Force

# Deshabilita avisos de apps del market actualizadas
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoNewAppAlert" -PropertyType DWord -Value 1 -Force

# Quitar OOBE de usuario
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -PropertyType DWord -Value 1 -Force

# App Browser Control (Edge SmartScreen para PUA)
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "SmartScreenPuaEnabled" -PropertyType DWord -Value 1 -Force

# Script de WinScript.cc, revisar todo lo que ha hecho y ponerlo aquí
Write-Host "-- Debloating Edge"
$EdgePolicies = @{
    EdgeEnhanceImagesEnabled = 0
    PersonalizationReportingEnabled = 0
    ShowRecommendationsEnabled = 0
    HideFirstRunExperience = 1
    UserFeedbackAllowed = 0
    ConfigureDoNotTrack = 1
    AlternateErrorPagesEnabled = 0
    EdgeCollectionsEnabled = 0
    EdgeFollowEnabled = 0
    EdgeShoppingAssistantEnabled = 0
    MicrosoftEdgeInsiderPromotionEnabled = 0
    RelatedMatchesCloudServiceEnabled = 0
    ShowMicrosoftRewards = 0
    WebWidgetAllowed = 0
    MetricsReportingEnabled = 0
    StartupBoostEnabled = 0
    BingAdsSuppression = 1
    NewTabPageHideDefaultTopSites = 0
    PromotionalTabsEnabled = 0
    SendSiteInfoToImproveServices = 0
    SpotlightExperiencesAndRecommendationsEnabled = 0
    DiagnosticData = 0
    EdgeAssetDeliveryServiceEnabled = 0
    CryptoWalletEnabled = 0
    WalletDonationEnabled = 0
}
foreach ($name in $EdgePolicies.Keys) {
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name $name -PropertyType DWord -Value $EdgePolicies[$name] -Force
}
Write-Host "-- Removing Copilot"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -PropertyType DWord -Value 0 -Force

Write-Host "-- Uninstalling Widgets"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -PropertyType DWord -Value 0 -Force
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy" -Force | Out-Null

Write-Host "-- Disable Taskbar Widgets"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -PropertyType DWord -Value 0 -Force

Write-Host "-- Disable Consumer Features"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -PropertyType DWord -Value 1 -Force

Write-Host "-- Disable Recall"
Disable-WindowsOptionalFeature -FeatureName Recall -Online -NoRestart -ErrorAction SilentlyContinue

Write-Host "-- Disable Hyper-V"
Try { Disable-WindowsOptionalFeature -FeatureName "Microsoft-Hyper-V-All" -Online -NoRestart -ErrorAction Stop } Catch { Write-Host "Hyper-V feature not found." }

Write-Host "-- Disable Fax and Scan"
Disable-WindowsOptionalFeature -FeatureName FaxServicesClientPackage -Online -NoRestart -ErrorAction SilentlyContinue
Stop-Service Fax -ErrorAction SilentlyContinue
Set-Service Fax -StartupType Manual -ErrorAction SilentlyContinue

Write-Host "-- Disable Xbox apps"
$XboxApps = @(
    "Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe",
    "Microsoft.Xbox.TCUI_8wekyb3d8bbwe",
    "Microsoft.XboxApp_8wekyb3d8bbwe",
    "Microsoft.XboxGamingOverlay_8wekyb3d8bbwe",
    "Microsoft.XboxGameOverlay_8wekyb3d8bbwe"
)
foreach ($app in $XboxApps) {
    Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\$app" -ErrorAction SilentlyContinue
}
$XboxServices = @(
	"XblAuthManager",
	"XblGameSave",
	"XboxGipSvc",
	"XboxNetApiSvc"
)
foreach ($svc in $XboxServices) { Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue }

Write-Host "-- Disable Map downloads"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Name "AllowUntriggeredNetworkTrafficOnSettingsPage" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Name "AutoDownloadAndUpdateMapData" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -PropertyType DWord -Value 0 -Force

Write-Host "-- Disable Activity Feed"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -PropertyType DWord -Value 0 -Force

Write-Host "-- Disable Cloud sync / SettingSync"
$SyncKeys = @{
    DisableSettingSync = 2
    DisableSettingSyncUserOverride = 1
    DisableSyncOnPaidNetwork = 1
    DisableApplicationSettingSync = 2
    DisableApplicationSettingSyncUserOverride = 1
    DisableAppSyncSettingSync = 2
    DisableAppSyncSettingSyncUserOverride = 1
    DisableCredentialsSettingSync = 2
    DisableCredentialsSettingSyncUserOverride = 1
    DisableDesktopThemeSettingSync = 2
    DisableDesktopThemeSettingSyncUserOverride = 1
    DisablePersonalizationSettingSync = 2
    DisablePersonalizationSettingSyncUserOverride = 1
    DisableStartLayoutSettingSync = 2
    DisableStartLayoutSettingSyncUserOverride = 1
    DisableWebBrowserSettingSync = 2
    DisableWebBrowserSettingSyncUserOverride = 1
    DisableWindowsSettingSync = 2
    DisableWindowsSettingSyncUserOverride = 1
}
foreach ($name in $SyncKeys.Keys) {
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" -Name $name -PropertyType DWord -Value $SyncKeys[$name] -Force
}

Write-Host "-- Disable Default0 User"
Remove-LocalUser -Name "defaultuser0" -ErrorAction SilentlyContinue

Write-Host "-- Disable Lock Screen Camera"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreenCamera" -PropertyType DWord -Value 1 -Force

Write-Host "-- Disable Telemetry & CEIP"
$CEIPTasks = @(
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\Feedback\Siuf\DmClient",
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting",
    "\Microsoft\Windows\Maps\MapsUpdateTask"
)
foreach ($task in $CEIPTasks) {
    schtasks /Change /TN $task /Disable | Out-Null
}
$TelemetryServices = @(
	"diagnosticshub.standardcollector.service",
	"diagsvc",
	"WerSvc",
	"wercplsupport"
)
foreach ($svc in $TelemetryServices) {
	Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowDesktopAnalyticsProcessing -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowDeviceNameInTelemetry -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name MicrosoftEdgeDataOptIn -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowWUfBCloudProcessing -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowUpdateComplianceProcessing -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowCommercialDataPipeline -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\SQMClient\Windows" -Name CEIPEnable -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name AllowTelemetry -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name DisableOneSettingsDownloads -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name Disabled -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name Disabled -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\Windows Error Reporting\Consent" -Name DefaultConsent -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\Windows Error Reporting\Consent" -Name DefaultOverrideBehavior -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\Windows Error Reporting" -Name DontSendAdditionalData -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\Windows Error Reporting" -Name LoggingDisabled -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications" -Name EnableAccountNotifications -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" -Name DisableMFUTracking -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name PublishUserActivities -PropertyType DWord -Value 0 -Force

Write-Host "-- Disable Windows Update P2P"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name DODownloadMode -PropertyType DWord -Value 0 -Force

Write-Host "-- Disabling Windows Search Telemetry"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name ConnectedSearchPrivacy -PropertyType DWord -Value 3 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name DisableSearchHistory -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowSearchToUseLocation -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name EnableDynamicContentInWSB -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name ConnectedSearchUseWeb -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name DisableWebSearch -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name DisableSearchBoxSuggestions -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name PreventUnwantedAddIns -PropertyType String -Value " " -Force
New-ItemProperty -Path "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AlwaysUseAutoLangDetection -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowIndexingEncryptedStoresOrItems -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name PreventRemoteQueries -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name CortanaInAmbientMode -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name ConnectedSearchUseWebOverMeteredConnections -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowCortanaAboveLock-PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowCortana -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name DisableVoice -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana" -Name value -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM\Software\Microsoft\Speech_OneCore\Preferences" -Name VoiceActivationDefaultOn -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name CortanaEnabled -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowCloudSearch -PropertyType DWord -Value 0 -Force
Write-Host "-- Disable Office telemetry tasks"
Disable-ScheduledTask -TaskPath "\Microsoft\Office\" -TaskName "OfficeTelemetryAgentFallBack" -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskPath "\Microsoft\Office\" -TaskName "OfficeTelemetryAgentLogOn" -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskPath "\Microsoft\Office\" -TaskName "OfficeTelemetryAgentFallBack2016" -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskPath "\Microsoft\Office\" -TaskName "OfficeTelemetryAgentLogOn2016" -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskPath "\Microsoft\Office\" -TaskName "Office 15 Subscription Heartbeat" -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskPath "\Microsoft\Office\" -TaskName "Office 16 Subscription Heartbeat" -ErrorAction SilentlyContinue

Write-Host "-- Disable Application Experience telemetry tasks"
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "Microsoft Compatibility Appraiser" -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "Microsoft Compatibility Appraiser Exp" -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "StartupAppTask" -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "PcaPatchDbTask" -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "MareBackup" -ErrorAction SilentlyContinue



Write-Host "-- Disable NVIDIA telemetry"
New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" -Name OptInOrOutPreference -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\FTS" -Name EnableRID44231 -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\FTS" -Name EnableRID64640 -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\FTS" -Name EnableRID66610 -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup" -Name SendTelemetryData -PropertyType DWord -Value 0 -Force
Get-ScheduledTask | Where-Object {$_.TaskName -like "{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"} | ForEach-Object { Disable-ScheduledTask -TaskPath $_.TaskPath -TaskName $_.TaskName }
Write-Host "-- Disable Visual Studio telemetry"
New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\VSCommon\14.0\SQM" -Name OptIn -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\VSCommon\15.0\SQM" -Name OptIn -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\VSCommon\16.0\SQM" -Name OptIn -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\VSCommon\17.0\SQM" -Name OptIn -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\VisualStudio\SQM" -Name OptIn -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Feedback" -Name DisableFeedbackDialog -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Feedback" -Name DisableEmailInput -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Feedback" -Name DisableScreenshotCapture -PropertyType DWord -Value 1 -Force
Remove-ItemProperty -Path "HKLM:\Software\Microsoft\VisualStudio\DiagnosticsHub" -Name LogLevel -ErrorAction SilentlyContinue

Write-Host "-- Disabling Windows Feedback Experience telemetry"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name DoNotShowFeedbackNotifications -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name DoNotShowFeedbackNotifications -PropertyType DWord -Value 1 -Force

Write-Host "-- Disabling Handwriting telemetry"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name RestrictImplicitInkCollection -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name RestrictImplicitTextCollection -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports" -Name PreventHandwritingErrorReports -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Name PreventHandwritingDataSharing -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name AllowInputPersonalization -PropertyType DWord -Value 0 -Force

Write-Host "-- Disabling Targeted Ads and Data Collection"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableSoftLanding -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name DisableWindowsSpotlightFeatures -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name DisableWindowsConsumerFeatures -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name DisabledByGroupPolicy -PropertyType DWord -Value 1 -Force

Write-Host "-- Disabling PowerShell telemetry"
setx POWERSHELL_TELEMETRY_OPTOUT 1

Write-Host "-- Disabling Google updates"
Set-Service -Name gupdate -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name gupdatem -StartupType Disabled -ErrorAction SilentlyContinue

Write-Host "-- Disabling Adobe updates"
Get-ScheduledTask -TaskName "Adobe Acrobat Update Task" -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue
Set-Service -Name AdobeARMservice -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name AdobeUpdateService -StartupType Disabled -ErrorAction SilentlyContinue

Write-Host "-- Disabling Game Mode"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AutoGameModeEnabled -PropertyType DWord -Value 0 -Force

Write-Host "-- Disabling Game Bar"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name AllowGameDVR -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -PropertyType DWord -Value 0 -Force

Write-Host "-- Limiting Windows Defender Usage"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" -Name AvgCPULoadFactor -PropertyType DWord -Value 25 -Force

Write-Host "-- Disabling Hibernation"
powercfg.exe /hibernate off

Write-Host "-- Disabling Sticky Keys"
Set-ItemProperty -Path "HKLM:\Control Panel\Accessibility\StickyKeys" -Name Flags -Value "58"
