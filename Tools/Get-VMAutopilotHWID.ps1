<#
.SYNOPSIS
    Copies the Autopilot hardware hash CSV out of a Hyper-V VM built with OSDCloud.

.DESCRIPTION
    Run on the Hyper-V host once the VM is sitting at OOBE. SetupComplete.ps1 writes
    C:\HWID\AutopilotHWID-<serial>.csv inside the guest; this script shuts the VM down,
    mounts its OS disk read-only, copies the CSV out and dismounts it. The VM is left off,
    since it needs a reboot after the Intune import to pick up the Autopilot profile anyway.

    Must be run elevated - Hyper-V Administrators membership alone is not enough to mount
    a VHD. Do not run this while Windows setup is still in progress - shutting down before
    OOBE will break the build.

.PARAMETER VMName
    Name of the Hyper-V VM.

.PARAMETER Destination
    Folder to copy the CSV to. Defaults to the current user's Desktop.

.PARAMETER Start
    Start the VM again afterwards.

.EXAMPLE
    .\Get-VMAutopilotHWID.ps1 -VMName CMW-MJ-VMTEST03
#>
#Requires -RunAsAdministrator
[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	[string]$VMName,

	[string]$Destination = [Environment]::GetFolderPath('Desktop'),

	[switch]$Start
)

$ErrorActionPreference = 'Stop'

$VM = Get-VM -Name $VMName

if ($VM.State -ne 'Off') {
	Write-Host "Shutting down $VMName..." -ForegroundColor Yellow
	Stop-VM -VM $VM
}

$VhdPath = (Get-VMHardDiskDrive -VM $VM | Select-Object -First 1).Path
$Disk = Mount-VHD -Path $VhdPath -ReadOnly -Passthru | Get-Disk

try {
	# Find the Windows partition by looking for the HWID folder
	$Source = $null
	foreach ($Partition in (Get-Partition -DiskNumber $Disk.Number | Where-Object Type -eq 'Basic')) {
		if (-not $Partition.DriveLetter) {
			$Partition | Add-PartitionAccessPath -AssignDriveLetter
			$Partition = Get-Partition -DiskNumber $Disk.Number -PartitionNumber $Partition.PartitionNumber
		}
		$HwidDir = "$($Partition.DriveLetter):\HWID"
		if (Test-Path $HwidDir) { $Source = $HwidDir; break }
	}

	if (-not $Source) { throw "No HWID folder found on $VhdPath - has SetupComplete run?" }

	$ErrorFile = Join-Path $Source 'HWID-error.txt'
	if (Test-Path $ErrorFile) {
		Write-Warning "Hash capture failed inside the guest:"
		Get-Content $ErrorFile | Write-Warning
	}

	$Csv = Get-ChildItem -Path $Source -Filter 'AutopilotHWID-*.csv'
	if (-not $Csv) { throw "No AutopilotHWID CSV found in $Source" }

	New-Item -Path $Destination -ItemType Directory -Force | Out-Null
	$Csv | Copy-Item -Destination $Destination -Force -PassThru |
		ForEach-Object { Write-Host "Copied $($_.FullName)" -ForegroundColor Green }
} finally {
	Dismount-VHD -DiskNumber $Disk.Number
	if ($Start) {
		Write-Host "Starting $VMName..." -ForegroundColor Yellow
		Start-VM -VM $VM
	} else {
		Write-Host "$VMName left off - start it once the Intune import has completed." -ForegroundColor Yellow
	}
}
