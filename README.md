
## **LANList PS Script**
![Static Badge](https://img.shields.io/badge/Author-Jgooch-1F4D37)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Static Badge](https://img.shields.io/badge/Distribution-npm-orange)
![Target](https://img.shields.io/badge/Target-Microsoft%20Windows%2011%20Professional-357EC7)

# Supported Platforms

![Windows Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Windows_logo_-_2021.svg/64px-Windows_logo_-_2021.svg.png) **Windows**

**LANList.ps1** is a PowerShell script that generates a report for all LAN machines. 
It collects IP addresses, MAC addresses, open ports, logged-in users, and the status of critical services like Remote Access and Windows Event Log. 

- **IP Address**: Retrieved via `Test-Connection`.
- **MAC Address**: Fetched using `Get-WmiObject` and `Win32_NetworkAdapterConfiguration`.
- **Logged-In User**: Retrieved using `Win32_ComputerSystem`.
- **Open Ports**: Listed using `Get-NetTCPConnection`.
- **Service Status**: Checks the status of key services such as:
  - **Remote Access Connection Manager** (`RemoteAccess`)
  - **Remote Access Auto Connection Manager** (`RasAuto`)
  - **Windows Event Log** (`EventLog`)
  - **Remote Registry** (`RemoteRegistry`)

The script consolidates the data and generates an HTML report.

---

## 💡 **Usage Example**

```powershell
PS C:\> .\LANList.ps1
