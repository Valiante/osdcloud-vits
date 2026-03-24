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

$BootMedia = Get-CimInstance Win32_LogicalDisk | Where-Object {
    $_.DriveType -eq 5 -and $_.VolumeName
} | Select-Object -First 1

if ($BootMedia) {
    $BootDeviceID = $BootMedia.DeviceID
    $BootVolumeName = $BootMedia.VolumeName

    do {
        Start-Sleep -Seconds 1

        $StillPresent = Get-CimInstance Win32_LogicalDisk | Where-Object {
            $_.DeviceID -eq $BootDeviceID -and $_.VolumeName -eq $BootVolumeName
        }
    } while ($StillPresent)
}

Write-Host "Boot media ejected. Continuing..." -ForegroundColor Green
Write-Host ""

Start-OSDCloud -OSName "Windows 11 25H2 x64" -OSEdition 'Enterprise' -OSActivation 'Retail' -OSLanguage 'en-gb'

wpeutil reboot