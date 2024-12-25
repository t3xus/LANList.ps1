
# **LANListPS**

![Static Badge](https://img.shields.io/badge/Author-Jgooch-1F4D37)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Static Badge](https://img.shields.io/badge/Distribution-npm-orange)
![Target](https://img.shields.io/badge/Target-Microsoft%20Windows%2011%20Professional-357EC7)

**LANListPS** is an all-in-one PowerShell tool for network auditing and reporting. 
It installs necessary dependencies, downloads the LANListPS script, and generates comprehensive network reports.

---

## **Features**
- **Installs Dependencies**: Automatically ensures required modules like Active Directory are installed.
- **Configures Remoting**: Enables and configures PowerShell remoting securely.
- **Network Reports**: Provides details such as:
  - IP Addresses
  - MAC Addresses
  - Open Ports
  - Logged-in Users
  - Service Statuses
  - Network Map (grouped by subnets)
- **Interactive HTML Report**: Reports include collapsible sections and visual enhancements.
- **Supports Multiple Formats**: Generate reports in HTML, CSV, or JSON.
- **Scheduling**: Easily schedule the script for recurring reports.
- **Execution Summary**: Summarizes results post-execution.

---

## **Usage Example**

1. **Run the Script**:
    ```powershell
    PS C:\> .\LANListPS.ps1
    ```

2. **Schedule the Script**:
    ```powershell
    PS C:\> .\LANListPS.ps1 -Schedule Daily -StartTime "3:00AM"
    ```

---

## **License**
Distributed under the MIT License. See the `LICENSE` file for more details.

---

## **Requirements**
- Windows PowerShell 5.1 or later.
- Administrative privileges.
- Active Directory environment.
