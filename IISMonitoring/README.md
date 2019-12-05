Credit: https://github.com/o0ste0o

This PowerShell script is intended for use with Zabbix 3.x and higher. The PowerShell script(s) must be placed in the 
C:\Scripts folder on each server, configured with the IIS Server Role.

Item prototypes: IIS AppPool (each Application Pool), IIS Site (each Site)
Discovery: All configured Application Pools and Sites, Running or Stopped
Trigger prototypes: [INFORMATION] => Last Result

Installation:
- Import template "zbx_template_IISMonitoring_LLD.xml" into Zabbix
  - Alternatively, import template "zbx_template_IISMonitoring.xml" for the complete monitoring set, which includes IIS performance monitoring
- Reconfigure the Zabbix agent on your host
- Add the following line to your Zabbix agent configuration file:
  - UnsafeUserParameters=1
  - UserParameter=apppool.discovery,powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\get_apppool.ps1"
  - UserParameter=apppool.state[*],powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\get_apppoolstate.ps1" "$1"
  - UserParameter=site.discovery,powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\get_sites.ps1"
  - UserParameter=site.state[*],powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\get_sitestate.ps1" "$1"
- Copy get_apppool.ps1, get_apppoolstate.ps1, get_sites.ps1 and get_sitestate.ps1 in C:\Scripts
- Restart the Zabbix Agent service