# **LANList Script**

> **Version:** 1.9  
> **Author:** James Gooch  
> **Compatibility:** Windows PowerShell 5.1 or later  
> **Required Dependencies:**  
> - Active Directory Module  
> - PowerShell Remoting (enabled)

---

## 📝 **Synopsis**

**LANList.ps1** is a PowerShell script that generates a report for all LAN machines. It collects IP addresses, MAC addresses, open ports, logged-in users, and the status of critical services like Remote Access and Windows Event Log. 

---

## 📋 **Description**

This script performs network discovery by gathering the following data from each machine on the domain:

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
