$Global:MyOSDCloud = [ordered]@{
    Restart               = [bool]$False
    RecoveryPartition     = [bool]$true
    OEMActivation         = [bool]$True
    WindowsUpdate         = [bool]$true
    WindowsUpdateDrivers  = [bool]$true
    WindowsDefenderUpdate = [bool]$true
    SetTimeZone           = [bool]$true
    ClearDiskConfirm      = [bool]$False
    ShutdownSetupComplete = [bool]$false
    SyncMSUpCatDriverUSB  = [bool]$true
    CheckSHA1             = [bool]$True
}

$banner = @"
//////////////////////////////////////////////////
//  ___  ____  ____   ____ _                 _  //
// / _ \/ ___||  _ \ / ___| | ___  _   _  __| | //
//| | | \___ \| | | | |   | |/ _ \| | | |/ _  | //
//| |_| |___) | |_| | |___| | (_) | |_| | (_| | //
// \___/|____/|____/ \____|_|\___/ \__,_|\__,_| //
//                                              //
//////////////////////////////////////////////////
"@

Write-Host $banner -ForegroundColor Yellow
Write-Host ""
Write-Host "Created by Dave Segura (@SeguraOSD)" -ForegroundColor White
Write-Host "Modified by Marc Jolley (@Valiante)" -ForegroundColor White
Write-Host ""
Write-Host "Waiting for boot media to be ejected..." -ForegroundColor Yellow

# The loop continues as long as the command returns an object ($true)
# It exits when the command returns nothing ($null/$false)
while (Get-CimInstance Win32_LogicalDisk | Where-Object { $_.VolumeName -like "OSDCloud*" }) {
    Start-Sleep -Seconds 1
}

Write-Host "Boot media ejected. Continuing..." -ForegroundColor Green
Write-Host ""

$RepoRoot = 'https://raw.githubusercontent.com/Valiante/osdcloud-vits/main'
$SetupCompletePath = 'X:\OSDCloud\Config\Scripts\SetupComplete'

New-Item -Path $SetupCompletePath -ItemType Directory -Force | Out-Null

Write-Host "Downloading SetupComplete files..." -ForegroundColor Yellow

Invoke-WebRequest -Uri "$RepoRoot/SetupComplete/SetupComplete.ps1" -OutFile "$SetupCompletePath\SetupComplete.ps1"
Invoke-WebRequest -Uri "$RepoRoot/SetupComplete/SetupComplete.cmd" -OutFile "$SetupCompletePath\SetupComplete.cmd"
Invoke-WebRequest -Uri "$RepoRoot/SetupComplete/LayoutModification.xml" -OutFile "$SetupCompletePath\LayoutModification.xml"

Write-Host "SetupComplete files staged." -ForegroundColor Green
Write-Host ""

Start-OSDCloud -OSName "Windows 11 25H2 x64" -OSEdition 'Enterprise' -OSActivation 'Retail' -OSLanguage 'en-gb'

wpeutil reboot