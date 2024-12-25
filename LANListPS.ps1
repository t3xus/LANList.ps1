
<#
.SYNOPSIS
    LANListPS Combined Script - Installer and Network Reporting Script.

.DESCRIPTION
    This script combines the installation of necessary dependencies, the downloading of the LANListPS script,
    and the execution of the network reporting functionality. It ensures the environment is configured
    properly and generates a detailed network report with a network map.

.NOTES
    Author: Gooch, James
    Version: 2.2
    Compatibility: Windows PowerShell 5.1 or later

.PARAMETERS
    None

.EXAMPLE
    PS C:\> .\LANListPS-Combined.ps1
    This command installs dependencies, configures the environment, and generates a network report.
#>

# Ensure script is run as Administrator
if (-not ([bool](whoami /groups | findstr "S-1-5-32-544"))) {
    Write-Error "Script must be run with administrative privileges."
    exit
}

# Verify PowerShell version
if (-not ($PSVersionTable.PSVersion.Major -ge 5)) {
    Write-Error "Windows PowerShell 5.1 or later is required."
    exit
}

# Define required modules, services, and other configurations
$requiredModules = @("ActiveDirectory")
$servicesToCheck = @("RemoteAccess", "RasAuto", "EventLog", "RemoteRegistry")
$iconUrl = "https://cdn.icon-icons.com/icons2/1875/PNG/512/lan_120078.png"
$desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "LANListPS.ps1")
$logFilePath = "C:\LANList-Log.txt"

# Initialize logging
Start-Transcript -Path $logFilePath
Write-Host "Log file initialized at $logFilePath"

# Function to install required modules
function Install-RequiredModules {
    foreach ($module in $requiredModules) {
        try {
            if (!(Get-Module -ListAvailable -Name $module)) {
                Write-Host "Installing required module: $module..."
                Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature
                Import-Module ActiveDirectory
            }
        } catch {
            Write-Error "Failed to install or load module $module: $_"
        }
    }
}

# Function to enable PowerShell Remoting
function Enable-PowerShellRemoting {
    Write-Host "Enabling PowerShell Remoting..."
    Enable-PSRemoting -Force
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"
}

# Function to download LANListPS script
function Download-LANListScript {
    Write-Host "Downloading LANListPS script to desktop..."
    $lanListScript = @"
# LANListPS.ps1 - Main script

# Define the list of services to check
\$ServicesToCheck = @(
    "RemoteAccess",  # Remote Access Connection Manager
    "RasAuto",       # Remote Access Auto Connection Manager
    "EventLog",      # Windows Event Log
    "RemoteRegistry" # Remote Registry
)

# Get list of machines from the network
\$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

# Initialize an array to hold all the computer info
\$computerInfo = @()

# Initialize network map data
\$networkMap = "<ul>"

# Loop through all machines on the network
foreach (\$computer in \$computers) {
    try {
        # Get the IP Address and MAC address
        \$networkInfo = Test-Connection -ComputerName \$computer -Count 1 | Select-Object Address, IPV4Address
        \$ipAddress = \$networkInfo.IPV4Address

        \$macAddress = (Get-CimInstance -ComputerName \$computer -ClassName Win32_NetworkAdapterConfiguration |
                      Where-Object { \$_.'IPEnabled' -eq \$true }).MACAddress

        # Get Logged in user
        \$loggedUser = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName \$computer | Select-Object -ExpandProperty UserName

        # Check open ports
        \$openPorts = Get-NetTCPConnection -ComputerName \$computer | Select-Object LocalPort, RemotePort, State

        # Check if the services are running
        \$servicesStatus = @{}
        foreach (\$service in \$ServicesToCheck) {
            \$serviceStatus = Get-Service -ComputerName \$computer -Name \$service | Select-Object -ExpandProperty Status
            \$servicesStatus[\$service] = \$serviceStatus
        }

        # Append the information for this computer to the array
        \$computerInfo += [pscustomobject]@{
            ComputerName  = \$computer
            IPAddress     = \$ipAddress
            MacAddress    = \$macAddress
            LoggedUser    = \$loggedUser
            OpenPorts     = \$openPorts.LocalPort -join ", "
            ServiceStatus = \$servicesStatus
        }

        # Append to network map
        \$networkMap += "<li>\$computer (\$ipAddress)</li>"

    } catch {
        Write-Warning "Failed to query computer \$computer: $_"
    }
}

# Close network map
\$networkMap += "</ul>"

# Backup existing report
if (Test-Path "C:\NetworkReport.html") {
    \$backupPath = "C:\Backup_NetworkReport_$(Get-Date -Format 'yyyyMMddHHmmss').html"
    Rename-Item -Path "C:\NetworkReport.html" -NewName \$backupPath
    Write-Host "Previous report backed up to \$backupPath"
}

# Convert to HTML and generate a report
\$HtmlReport = "<html><head><style>table { border-collapse: collapse; width: 100%; } th, td { border: 1px solid black; padding: 8px; text-align: left; } th { background-color: #f2f2f2; }</style></head><body>"
\$HtmlReport += "<h1>Network Report</h1>"
\$HtmlReport += "<h2>Network Map</h2>\$networkMap"
\$HtmlReport += "<h2>Computer Details</h2>"
\$HtmlReport += (\$computerInfo | ConvertTo-Html -Property ComputerName, IPAddress, MacAddress, LoggedUser, OpenPorts, ServiceStatus -Fragment)
\$HtmlReport += "</body></html>"

# Output to an HTML file
\$HtmlReport | Out-File -FilePath "C:\NetworkReport.html"

Write-Host "Network report generated at C:\NetworkReport.html"
"@

    Set-Content -Path $desktopPath -Value $lanListScript
    Write-Host "LANListPS script downloaded to: $desktopPath"
}

# Function to set the icon for the script on the desktop
function Set-ScriptIcon {
    Write-Host "Downloading LANListPS icon..."
    $iconPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "lan_icon.ico")
    try {
        Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath
    } catch {
        Write-Warning "Failed to download icon. Using default icon."
    }

    Write-Host "Setting script to use the downloaded icon..."
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut("$desktopPath.lnk")
    $shortcut.TargetPath = $desktopPath
    $shortcut.IconLocation = $iconPath
    $shortcut.Save()
}

# Cleanup Function
function Cleanup-Files {
    Write-Host "Cleaning up temporary files..."
    Remove-Item -Path "C:\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Temporary files cleaned up."
}

# Main Execution

# 1. Install Required Modules
Install-RequiredModules

# 2. Enable PowerShell Remoting
Enable-PowerShellRemoting

# 3. Download LANListPS Script
Download-LANListScript

# 4. Set the icon for the LANListPS script
Set-ScriptIcon

# 5. Generate Network Report
Write-Host "Running LANListPS script to generate a network report..."
Invoke-Expression $desktopPath

# 6. Cleanup Temporary Files
Cleanup-Files

# End Logging
Stop-Transcript
Write-Host "Execution completed. Log available at $logFilePath."
