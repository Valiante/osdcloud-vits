$DefaultHive = 'C:\Users\Default\NTUSER.DAT'

# Load Default User hive
reg load HKU\DefUser $DefaultHive | Out-Null

try {
	# ========================
	# Explorer - General
	# ========================
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer' /v ShowFrequent /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer' /v ShowRecent /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer' /v ShowRecommendations /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer' /v ShowCloudFilesInQuickAccess /t REG_DWORD /d 0 /f | Out-Null

	# ========================
	# Explorer - Advanced
	# ========================
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v LaunchTo /t REG_DWORD /d 1 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v Hidden /t REG_DWORD /d 1 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v HideFileExt /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v AutoCheckSelect /t REG_DWORD /d 0 /f | Out-Null

	# ========================
	# Explorer - Performance
	# ========================
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager' /v EnthusiastMode /t REG_DWORD /d 1 /f | Out-Null

	# ========================
	# Search
	# ========================
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Search' /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f | Out-Null

	# ========================
	# Taskbar
	# ========================
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v ShowTaskViewButton /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v TaskbarAl /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v TaskbarAutoHideInTabletMode /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v TaskbarBadges /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v TaskbarFlashing /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v TaskbarGlomLevel /t REG_DWORD /d 1 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v TaskbarSd /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v TaskbarSn /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v ExpandableTaskbar /t REG_DWORD /d 0 /f | Out-Null

	# ========================
	# File association - .log
	# ========================
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.log\OpenWithList' /v a /t REG_SZ /d CMPowerLogViewer.exe /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.log\OpenWithList' /v MRUList /t REG_SZ /d a /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.log\UserChoice' /v ProgId /t REG_SZ /d LogFile /f | Out-Null

	# ========================
	# Dark mode (this replaces your .theme launch)
	# ========================
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' /v AppsUseLightTheme /t REG_DWORD /d 0 /f | Out-Null
	reg add 'HKU\DefUser\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' /v SystemUsesLightTheme /t REG_DWORD /d 0 /f | Out-Null

} finally {
	reg unload HKU\DefUser | Out-Null
}

# ========================
# HKLM policy (unchanged)
# ========================
reg add 'HKLM\SOFTWARE\Policies\Microsoft\Dsh' /v AllowNewsAndInterests /t REG_DWORD /d 0 /f | Out-Null

# ====================================================
# Copy LayoutModification.xml to Default User profile
# ====================================================
$SourceLayoutFile = Join-Path $PSScriptRoot 'LayoutModification.xml'
$DestinationFolder = 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell'
$DestinationLayoutFile = Join-Path $DestinationFolder 'LayoutModification.xml'

# Ensure folder exists
If (-not (Test-Path $DestinationFolder)) {
	New-Item -Path $DestinationFolder -ItemType Directory -Force | Out-Null
}

# Copy file
Copy-Item -Path $SourceLayoutFile -Destination $DestinationLayoutFile -Force