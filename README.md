# LANList.ps1

PowerShell script designed to collect network information from all LAN computers and generate an HTML report.

## Features

Checks the following Windows services on each computer:
- **Remote Access Connection Manager** (`RemoteAccess`)
- **Remote Access Auto Connection Manager** (`RasAuto`)
- **Windows Event Log** (`EventLog`)
- **Remote Registry** (`RemoteRegistry`)

### Network Machine Discovery:
- Uses `Get-ADComputer` to retrieve the list of computers in your Active Directory domain.

### Gathering Data from Each Machine:
- **IP Address**: Uses `Test-Connection` to retrieve the IPv4 addresses.
- **MAC Address**: Uses `Get-WmiObject` and `Win32_NetworkAdapterConfiguration` to get the MAC addresses.
- **Logged-In User**: Uses `Win32_ComputerSystem` to get current user.
- **Open Ports**: Uses `Get-NetTCPConnection` to list open ports.
- **Service Status**: Uses `Get-Service` for service state.

### Output:
- Script generates an HTML report using `ConvertTo-Html`.

## How to Use

### Prepare the Environment:
1. **Ensure that PowerShell Remoting is enabled** on all target machines.
2. **Ensure the Active Directory module is installed and imported**:
   ```powershell
   Import-Module ActiveDirectory

### Running LanList.ps1:

1. **Install with LANList-Installer.ps1
2. **Double click the LanList.ps1 on your desktop.**:
