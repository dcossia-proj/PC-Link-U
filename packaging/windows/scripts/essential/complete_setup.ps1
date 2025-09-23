# PowerShell script for PC-Link-U setup

   # Self-elevate if not running as administrator
   if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
       Write-Host "Relaunching as administrator..."
       Start-Process PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
       exit $LASTEXITCODE
   }

   Write-Host "Checking for OBS Studio installation..."
   $obsExePath = "C:\Program Files\obs-studio\bin\64bit\obs64.exe"
   $obsLog = Join-Path -Path $env:TEMP -ChildPath "obs_install.log"
   $obsErrorLog = Join-Path -Path $env:TEMP -ChildPath "obs_install_error.log"
   if (Test-Path $obsExePath) {
       Write-Host "OBS Studio is already installed at $obsExePath. Skipping installation."
       Add-Content -Path $obsLog -Value "OBS Studio is already installed at $obsExePath. Skipped installation." -ErrorAction SilentlyContinue
   }
   else {
       Write-Host "Installing OBS Studio silently..."
       try {
           $obsInstaller = Join-Path -Path $PSScriptRoot -ChildPath "..\..\extra\OBS-Studio-Installer.exe"
           $process = Start-Process -FilePath $obsInstaller -ArgumentList "/S","/D=`"$env:ProgramFiles\obs-studio`"" -Wait -NoNewWindow -PassThru -RedirectStandardOutput $obsLog -RedirectStandardError $obsErrorLog
           if ($process.ExitCode -eq 0) {
               Write-Host "OBS Studio installed successfully."
           } else {
               Write-Host "OBS Studio installation failed. Exit code: $($process.ExitCode)"
               Write-Host "See $obsLog and $obsErrorLog for details."
           }
       }
       catch {
           Write-Host "OBS Studio installation failed. Error: $_"
           Write-Host "See $obsLog and $obsErrorLog for details."
       }
   }

   Write-Host "Running apollofleet.exe (7z self-extractor)..."
   try {
       $apolloFleetExe = Join-Path -Path $PSScriptRoot -ChildPath "..\..\extra\apollofleet.exe"
       $apolloFleetLog = Join-Path -Path $env:TEMP -ChildPath "apollofleet.log"
       $apolloFleetErrorLog = Join-Path -Path $env:TEMP -ChildPath "apollofleet_error.log"
       $process = Start-Process -FilePath $apolloFleetExe -Wait -NoNewWindow -PassThru -RedirectStandardOutput $apolloFleetLog -RedirectStandardError $apolloFleetErrorLog
       if ($process.ExitCode -eq 0) {
           Write-Host "apollofleet.exe completed successfully."
       } else {
           Write-Host "Failed to run apollofleet.exe. Exit code: $($process.ExitCode)"
           Write-Host "See $apolloFleetLog and $apolloFleetErrorLog for details."
       }
   }
   catch {
       Write-Host "Failed to run apollofleet.exe. Error: $_"
       Write-Host "See $apolloFleetLog and $apolloFleetErrorLog for details."
   }

   Write-Host "Generating configuration files..."
   try {
       $apolloDir = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\ApolloFleet"
       $configDir = Join-Path -Path $apolloDir -ChildPath "config"
       $configLog = Join-Path -Path $env:TEMP -ChildPath "generate_config_files.log"
       $configErrorLog = Join-Path -Path $env:TEMP -ChildPath "generate_config_files_error.log"

       # Create directories
       if (-not (Test-Path $apolloDir)) { New-Item -Path $apolloDir -ItemType Directory -Force | Out-Null }
       if (-not (Test-Path $configDir)) { New-Item -Path $configDir -ItemType Directory -Force | Out-Null }

       # Write settings.ini
       Write-Host "Writing settings.ini..."
       $settingsContent = @"
[Manager]
AutoStart=1
SyncVolume=1
RemoveDisconnected=1
DarkTheme=1
ShowErrors=1
[Window]
restorePosition=1
[Paths]
Apollo=C:\Program Files\PC-Link-U
Config=$($env:USERPROFILE)\Documents\ApolloFleet\config
ADB=$($env:USERPROFILE)\Documents\ApolloFleet\bin\platform-tools
[Android]
ReverseTethering=0
MicDeviceID=Unset
CamDeviceID=Unset
MicEnable=0
CamEnable=0
[Instance1]
Name=Asymetrical Mode
Port=11000
Enabled=1
AudioDevice=Unset
HeadlessModeSet=enabled
[Instance2]
Name=Mirror Mode
Port=12000
Enabled=1
AudioDevice=Unset
HeadlessModeSet=disabled
[Instance3]
Name=Solo Mode
Port=13000
Enabled=1
AudioDevice=Unset
HeadlessModeSet=enabled
"@
       $settingsContent | Out-File -FilePath (Join-Path -Path $apolloDir -ChildPath "settings.ini") -Encoding ASCII -ErrorAction Stop
       Add-Content -Path $configLog -Value "settings.ini created successfully." -ErrorAction Stop

       # Write fleet-1.conf
       Write-Host "Writing fleet-1.conf..."
       $fleet1Content = @"
credentials_file = $($env:USERPROFILE)\Documents\ApolloFleet\config\state-1.json
dd_configuration_option = ensure_active
double_refreshrate = enabled
enable_input_only_mode = enabled
file_apps = $($env:USERPROFILE)\Documents\ApolloFleet\config\apps-1.json
file_state = $($env:USERPROFILE)\Documents\ApolloFleet\config\state-1.json
keep_sink_default = disabled
log_path = $($env:USERPROFILE)\Documents\ApolloFleet\config\fleet-1.log
port = 11000
sunshine_name = Asymetrical Mode
"@
       $fleet1Content | Out-File -FilePath (Join-Path -Path $configDir -ChildPath "fleet-1.conf") -Encoding ASCII -ErrorAction Stop
       Add-Content -Path $configLog -Value "fleet-1.conf created successfully." -ErrorAction Stop

       # Write fleet-2.conf
       Write-Host "Writing fleet-2.conf..."
       $fleet2Content = @"
credentials_file = $($env:USERPROFILE)\Documents\ApolloFleet\config\state-2.json
double_refreshrate = enabled
file_apps = $($env:USERPROFILE)\Documents\ApolloFleet\config\apps-2.json
file_state = $($env:USERPROFILE)\Documents\ApolloFleet\config\state-2.json
keep_sink_default = disabled
log_path = $($env:USERPROFILE)\Documents\ApolloFleet\config\fleet-2.log
output_name = {30fd6e56-3a14-5539-9f24-61c606529fcb}
port = 12000
sunshine_name = Mirror Mode
"@
       $fleet2Content | Out-File -FilePath (Join-Path -Path $configDir -ChildPath "fleet-2.conf") -Encoding ASCII -ErrorAction Stop
       Add-Content -Path $configLog -Value "fleet-2.conf created successfully." -ErrorAction Stop

       # Write fleet-3.conf
       Write-Host "Writing fleet-3.conf..."
       $fleet3Content = @"
credentials_file = $($env:USERPROFILE)\Documents\ApolloFleet\config\state-3.json
dd_configuration_option = ensure_only_display
double_refreshrate = enabled
file_apps = $($env:USERPROFILE)\Documents\ApolloFleet\config\apps-3.json
file_state = $($env:USERPROFILE)\Documents\ApolloFleet\config\state-3.json
headless_mode = enabled
keep_sink_default = disabled
log_path = $($env:USERPROFILE)\Documents\ApolloFleet\config\fleet-3.log
port = 13000
sunshine_name = Solo Mode
"@
       $fleet3Content | Out-File -FilePath (Join-Path -Path $configDir -ChildPath "fleet-3.conf") -Encoding ASCII -ErrorAction Stop
       Add-Content -Path $configLog -Value "fleet-3.conf created successfully." -ErrorAction Stop

       Write-Host "Configuration files generated successfully in $apolloDir and $configDir"
   }
   catch {
       Write-Host "Failed to generate configuration files. Error: $_"
       Write-Host "See $configLog and $configErrorLog for details."
       Add-Content -Path $configErrorLog -Value "Error: $_" -ErrorAction SilentlyContinue
   }

   Write-Host "Running ApolloFleet.exe from Documents..."
   $apolloFleetExePath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\ApolloFleet\ApolloFleet.exe"
   $apolloFleetExeLog = Join-Path -Path $env:TEMP -ChildPath "apollofleet_exe.log"
   $apolloFleetExeErrorLog = Join-Path -Path $env:TEMP -ChildPath "apollofleet_exe_error.log"
   if (Test-Path $apolloFleetExePath) {
       try {
           Start-Process -FilePath $apolloFleetExePath -NoNewWindow -RedirectStandardOutput $apolloFleetExeLog -RedirectStandardError $apolloFleetExeErrorLog
           Write-Host "ApolloFleet.exe launched successfully."
       }
       catch {
           Write-Host "Failed to launch ApolloFleet.exe. Error: $_"
           Write-Host "See $apolloFleetExeLog and $apolloFleetExeErrorLog for details."
       }
       Write-Host "Press any key to continue or wait 10 seconds to exit..."
       $timeout = 10
       $startTime = Get-Date
       while (((Get-Date) - $startTime).TotalSeconds -lt $timeout) {
           if ([Console]::KeyAvailable) {
               $null = [Console]::ReadKey($true)
               break
           }
           Start-Sleep -Milliseconds 100
       }
   }
   else {
       Write-Host "Error: ApolloFleet.exe not found at $apolloFleetExePath"
       Write-Host "Press any key to continue or wait 10 seconds to exit..."
       $timeout = 10
       $startTime = Get-Date
       while (((Get-Date) - $startTime).TotalSeconds -lt $timeout) {
           if ([Console]::KeyAvailable) {
               $null = [Console]::ReadKey($true)
               break
           }
           Start-Sleep -Milliseconds 100
       }
   }

   Write-Host "PC-Link-U setup complete!"