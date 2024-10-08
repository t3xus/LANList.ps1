# LANList-Installer.ps1
<#
.SYNOPSIS
    LANList Installer Script - Installs LANList.ps1 and required dependencies.

.DESCRIPTION
    This script ensures that all necessary dependencies for the LANList script are installed,
    such as the Active Directory module and PowerShell remoting. It downloads the LANList.ps1
    script to the user's desktop, assigns ownership to the current user, and sets the script's
    icon to the specified LAN icon.

.PARAMETERS
    None

.NOTES
    Author: Gooch, James
    Version: 1.0
    Required Dependencies:
        - PowerShell Active Directory Module
        - PowerShell Remoting (enabled)
    Compatibility:
        - Windows PowerShell 5.1 or later

.EXAMPLE
    PS C:\> .\LANList-Installer.ps1
    This command installs LANList.ps1 on the user's desktop and sets up all required dependencies.
#>


# Define required services and modules
$requiredModules = @("ActiveDirectory")
$servicesToCheck = @("RemoteAccess", "RasAuto", "EventLog", "RemoteRegistry")
$iconUrl = "https://cdn.icon-icons.com/icons2/1875/PNG/512/lan_120078.png"

# Get the current logged-in user
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "LANList.ps1")

# Function to check and install missing PowerShell modules
function Install-RequiredModules {
    foreach ($module in $requiredModules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing required module: $module..."
            Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature
            Import-Module ActiveDirectory
        }
    }
}

# Function to enable PowerShell Remoting
function Enable-PowerShellRemoting {
    Write-Host "Enabling PowerShell Remoting..."
    Enable-PSRemoting -Force
}

# Function to download LANList script
function Download-LANListScript {
    Write-Host "Downloading LANList script to desktop..."
    $lanListScript = @"
# LANList.ps1 - Main script

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

# Loop through all machines on the network
foreach (\$computer in \$computers) {
    try {
        # Get the IP Address and MAC address
        \$networkInfo = Test-Connection -ComputerName \$computer -Count 1 | Select-Object Address, IPV4Address
        \$ipAddress = \$networkInfo.IPV4Address

        \$macAddress = (Get-WmiObject -ComputerName \$computer -Class Win32_NetworkAdapterConfiguration | 
                      Where-Object { \$_.'IPEnabled' -eq \$true }).MACAddress
        
        # Get Logged in user
        \$loggedUser = Get-WmiObject -Class Win32_ComputerSystem -ComputerName \$computer | Select-Object -ExpandProperty UserName

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
            ComputerName = \$computer
            IPAddress    = \$ipAddress
            MacAddress   = \$macAddress
            LoggedUser   = \$loggedUser
            OpenPorts    = \$openPorts.LocalPort -join ", "
            ServiceStatus = \$servicesStatus
        }
    } catch {
        Write-Host "Failed to query computer \$computer: \$_"
    }
}

# Convert to HTML and generate a report
\$HtmlReport = \$computerInfo | ConvertTo-Html -Property ComputerName, IPAddress, MacAddress, LoggedUser, OpenPorts, ServiceStatus -Head "<style>table { border-collapse: collapse; width: 100%; } th, td { border: 1px solid black; padding: 8px; text-align: left; } th { background-color: #f2f2f2; }</style>"

# Output to an HTML file
\$HtmlReport | Out-File -FilePath "C:\NetworkReport.html"

Write-Host "Network report generated at C:\NetworkReport.html"
"@

    Set-Content -Path $desktopPath -Value $lanListScript
    Write-Host "LANList script downloaded to: $desktopPath"
}

# Function to set the icon for the script on the desktop
function Set-ScriptIcon {
    Write-Host "Downloading LANList icon..."
    $iconPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "lan_icon.ico")
    Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath
    Write-Host "Icon downloaded to: $iconPath"

    Write-Host "Setting script to use the downloaded icon..."
    # Windows shortcuts are created using WScript.Shell, and they can have icons
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut("$desktopPath.lnk")
    $shortcut.TargetPath = $desktopPath
    $shortcut.IconLocation = $iconPath
    $shortcut.Save()
}

# Main Installation Process

# 1. Install Required Modules
Install-RequiredModules

# 2. Enable PowerShell Remoting if not already enabled
Enable-PowerShellRemoting

# 3. Download LANList Script to Desktop
Download-LANListScript

# 4. Set the icon for the LANList.ps1 script on the desktop
Set-ScriptIcon

# 5. Set script ownership to the current user
Write-Host "Setting ownership of script to current user: $currentUser"
Takeown /F $desktopPath
Icacls $desktopPath /grant $currentUser:F
