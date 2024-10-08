<#
.SYNOPSIS
    LANList Script - Generates a network report for all machines on the domain.

.DESCRIPTION
    The LANList script gathers information from all machines on the network, including IP addresses,
    MAC addresses, open ports, logged-in users, and the status of specific services such as Remote Access
    and Windows Event Log. It outputs this data in an HTML report.

.PARAMETERS
    None

.NOTES
    Author: Gooch, James
    Version: 1.9
    Required Dependencies:
        - Active Directory Module
        - PowerShell Remoting (enabled)
    Compatibility:
        - Windows PowerShell 5.1 or later

.EXAMPLE
    PS C:\> .\LANList.ps1
    This command runs the LANList script and generates a network report in HTML format at C:\NetworkReport.html.
#>

# Define the list of services to check
$ServicesToCheck = @(
    "RemoteAccess",  # Remote Access Connection Manager
    "RasAuto",       # Remote Access Auto Connection Manager
    "EventLog",      # Windows Event Log
    "RemoteRegistry" # Remote Registry
)

# Get list of machines from the network (adjust as needed)
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

# Initialize an array to hold all the computer info
$computerInfo = @()

# Loop through all machines on the network
foreach ($computer in $computers) {
    try {
        # Get the IP Address and MAC address
        $networkInfo = Test-Connection -ComputerName $computer -Count 1 | Select-Object Address, IPV4Address
        $ipAddress = $networkInfo.IPV4Address

        $macAddress = (Get-WmiObject -ComputerName $computer -Class Win32_NetworkAdapterConfiguration | 
                      Where-Object { $_.IPEnabled -eq $true }).MACAddress
        
        # Get Logged in user
        $loggedUser = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer | Select-Object -ExpandProperty UserName

        # Check open ports (replace with more sophisticated tools if needed)
        $openPorts = Get-NetTCPConnection -ComputerName $computer | Select-Object LocalPort, RemotePort, State

        # Check if the services are running
        $servicesStatus = @{}
        foreach ($service in $ServicesToCheck) {
            $serviceStatus = Get-Service -ComputerName $computer -Name $service | Select-Object -ExpandProperty Status
            $servicesStatus[$service] = $serviceStatus
        }

        # Append the information for this computer to the array
        $computerInfo += [pscustomobject]@{
            ComputerName = $computer
            IPAddress    = $ipAddress
            MacAddress   = $macAddress
            LoggedUser   = $loggedUser
            OpenPorts    = $openPorts.LocalPort -join ", "  # Simplified
            ServiceStatus = $servicesStatus
        }
    } catch {
        Write-Host "Failed to query computer $computer: $_"
    }
}

# Convert to HTML and generate a report
$HtmlReport = $computerInfo | ConvertTo-Html -Property ComputerName, IPAddress, MacAddress, LoggedUser, OpenPorts, ServiceStatus -Head "<style>table { border-collapse: collapse; width: 100%; } th, td { border: 1px solid black; padding: 8px; text-align: left; } th { background-color: #f2f2f2; }</style>"

# Output to an HTML file
$HtmlReport | Out-File -FilePath "C:\NetworkReport.html"

Write-Host "Network report generated at C:\NetworkReport.html"
