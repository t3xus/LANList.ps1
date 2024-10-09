![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white) 
## **LANList PS Script**
![Static Badge](https://img.shields.io/badge/Author-Jgooch-1F4D37)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Static Badge](https://img.shields.io/badge/Distribution-npm-orange)
![Target](https://img.shields.io/badge/Target-Microsoft%20Windows%2011%20Professional-357EC7)


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

## ⚙️ **Parameters**

> None. Note: May use desktop icon to start if installed with LanList-Installer.ps1

---

## 💡 **Usage Example**

```powershell
PS C:\> .\LANList.ps1
