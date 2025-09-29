# complete_setup.ps1
# This script sets up PC-Link-U by generating configuration files and installing ApolloFleet.

# Check if script is running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script requires administrative privileges. Please run as Administrator."
    exit 1
}

# Define paths
$installDir = "C:\Program Files\PC-Link-U"
$apolloFleetExe = Join-Path $installDir "apollofleet.exe"
$docsDir = Join-Path $env:USERPROFILE "Documents"
$apolloFleetDir = Join-Path $docsDir "ApolloFleet"
$configDir = Join-Path $apolloFleetDir "config"
$logFile = Join-Path $env:TEMP "generate_config_files.log"
$errorLogFile = Join-Path $env:TEMP "generate_config_files_error.log"

# Function to log messages
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
}

# Function to log errors
function Write-ErrorLog {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - ERROR: $Message" | Out-File -FilePath $errorLogFile -Append
    Write-Host "ERROR: $Message"
}

# Create log files if they don't exist
if (-not (Test-Path $logFile)) { New-Item -Path $logFile -ItemType File -Force | Out-Null }
if (-not (Test-Path $errorLogFile)) { New-Item -Path $errorLogFile -ItemType File -Force | Out-Null }

Write-Log "Starting PC-Link-U setup process..."

# Verify apollofleet.exe exists
if (-not (Test-Path $apolloFleetExe)) {
    Write-ErrorLog "apollofleet.exe not found at $apolloFleetExe"
    exit 1
}

# Run apollofleet.exe silently to extract to Documents\ApolloFleet
try {
    Write-Log "Running apollofleet.exe silently to extract to $apolloFleetDir"
    Start-Process -FilePath $apolloFleetExe -ArgumentList "-o`"$docsDir`" -y" -Wait
    Write-Log "apollofleet.exe extracted successfully to $apolloFleetDir"
} catch {
    Write-ErrorLog "Failed to extract apollofleet.exe: $_"
    exit 1
}

# Create ApolloFleet config directory
if (-not (Test-Path $configDir)) {
    try {
        New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        Write-Log "Created ApolloFleet config directory: $configDir"
    } catch {
        Write-ErrorLog "Failed to create config directory: $_"
        exit 1
    }
}

# Check for existing apps.json from Apollo or Sunshine
$apolloConfigDir = "C:\Program Files\Apollo\config"
$sunshineConfigDir = "C:\Program Files\Sunshine\config"
$appsJson = $null

if (Test-Path (Join-Path $apolloConfigDir "apps.json")) {
    $appsJson = Join-Path $apolloConfigDir "apps.json"
    Write-Log "Found apps.json in Apollo config: $appsJson"
} elseif (Test-Path (Join-Path $sunshineConfigDir "apps.json")) {
    $appsJson = Join-Path $sunshineConfigDir "apps.json"
    Write-Log "Found apps.json in Sunshine config: $appsJson"
} else {
    Write-Log "No apps.json found in Apollo or Sunshine config directories."
}

# Copy and rename apps.json if found
if ($appsJson) {
    try {
        Copy-Item -Path $appsJson -Destination (Join-Path $configDir "apps-1.json") -Force
        Copy-Item -Path $appsJson -Destination (Join-Path $configDir "apps-2.json") -Force
        Copy-Item -Path $appsJson -Destination (Join-Path $configDir "apps-3.json") -Force
        Write-Log "Created apps-1.json, apps-2.json, and apps-3.json in $configDir"
    } catch {
        Write-ErrorLog "Failed to copy apps.json files: $_"
        exit 1
    }
}

# Run Apollo or Sunshine uninstaller non-silently if present
$apolloUninstaller = "C:\Program Files\Apollo\Uninstall.exe"
$sunshineUninstaller = "C:\Program Files\Sunshine\Uninstall.exe"

if (Test-Path $apolloUninstaller) {
    try {
        Write-Log "Running Apollo uninstaller: $apolloUninstaller"
        Start-Process -FilePath $apolloUninstaller -Wait
        Write-Log "Apollo uninstaller executed successfully."
    } catch {
        Write-ErrorLog "Failed to run Apollo uninstaller: $_"
    }
} elseif (Test-Path $sunshineUninstaller) {
    try {
        Write-Log "Running Sunshine uninstaller: $sunshineUninstaller"
        Start-Process -FilePath $sunshineUninstaller -Wait
        Write-Log "Sunshine uninstaller executed successfully."
    } catch {
        Write-ErrorLog "Failed to run Sunshine uninstaller: $_"
    }
} else {
    Write-Log "No Apollo or Sunshine uninstaller found."
}

# Generate configuration files
try {
    Write-Log "Generating configuration files in $configDir"
    
    # settings.ini
    $settingsIni = @"
[General]
instances=3
default_instance=1
"@
    $settingsIniPath = Join-Path $configDir "settings.ini"
    Set-Content -Path $settingsIniPath -Value $settingsIni -Force
    Write-Log "Created $settingsIniPath"

    # fleet-1.conf (Asymmetrical Mode)
    $fleet1Conf = @"
[general]
name=Asymmetrical Mode
port=47990
enable_input_only_mode=enabled
"@
    $fleet1ConfPath = Join-Path $configDir "fleet-1.conf"
    Set-Content -Path $fleet1ConfPath -Value $fleet1Conf -Force
    Write-Log "Created $fleet1ConfPath"

    # fleet-2.conf (Mirror Mode)
    $fleet2Conf = @"
[general]
name=Mirror Mode
port=47991
mirror_mode=enabled
"@
    $fleet2ConfPath = Join-Path $configDir "fleet-2.conf"
    Set-Content -Path $fleet2ConfPath -Value $fleet2Conf -Force
    Write-Log "Created $fleet2ConfPath"

    # fleet-3.conf (Solo Mode)
    $fleet3Conf = @"
[general]
name=Solo Mode
port=47992
solo_mode=enabled
"@
    $fleet3ConfPath = Join-Path $configDir "fleet-3.conf"
    Set-Content -Path $fleet3ConfPath -Value $fleet3Conf -Force
    Write-Log "Created $fleet3ConfPath"
} catch {
    Write-ErrorLog "Failed to generate configuration files: $_"
    exit 1
}

# Launch ApolloFleet
$apolloFleetExeFinal = Join-Path $apolloFleetDir "ApolloFleet.exe"
if (Test-Path $apolloFleetExeFinal) {
    try {
        Write-Log "Launching ApolloFleet: $apolloFleetExeFinal"
        Start-Process -FilePath $apolloFleetExeFinal
        Write-Log "ApolloFleet launched successfully."
    } catch {
        Write-ErrorLog "Failed to launch ApolloFleet: $_"
        exit 1
    }
} else {
    Write-ErrorLog "ApolloFleet.exe not found at $apolloFleetExeFinal"
    exit 1
}

Write-Log "PC-Link-U setup completed successfully."
Write-Host "Setup completed. Check $logFile for details or $errorLogFile for errors."