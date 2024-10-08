# LANList.ps1
PowerShell script designed to collect network information from all LAN computers and generate an HTML report. 

The script checks the following Windows services on each computer:
Remote Access Connection Manager (RemoteAccess)
Remote Access Auto Connection Manager (RasAuto)
Windows Event Log (EventLog)
Remote Registry (RemoteRegistry)

Network Machine Discovery:
Uses Get-ADComputer to retrieve the list of computers in your Active Directory domain.

Gathering Data from Each Machine:
IP Address: Uses Test-Connection to ping the machine and retrieve the IPv4 address.
MAC Address: Uses Get-WmiObject and Win32_NetworkAdapterConfiguration to get the MAC address of each machine's network adapter.
Logged-In User: Retrieves the currently logged-in user via Win32_ComputerSystem.
Open Ports: Uses Get-NetTCPConnection to retrieve a list of open ports.
Service Status: Uses Get-Service to check whether the specified services are running on each machine.

Output: All the gathered data is combined into an array of objects and then converted into a modern-looking HTML report using ConvertTo-Html.
The output HTML file contains a table of results with relevant network and service information for each machine on the network.


Prepare the Environment:
Ensure that PowerShell Remoting is enabled on all target machines.
Ensure the Active Directory module is installed and imported (Import-Module ActiveDirectory).
Verify that you have appropriate administrative privileges on all the machines.

Download or Copy the Script:
Save the provided script into a .ps1 file (e.g., NetworkReport.ps1).

Run PowerShell as Administrator:
Open PowerShell with administrator privileges by right-clicking the PowerShell icon and selecting "Run as Administrator".

Execute the Script:
In the PowerShell window, navigate to the directory where your script is saved:
Run with: .\NetworkReport.ps1

View the Report:
Once the script has finished running, an HTML report will be generated at C:\NetworkReport.html.
