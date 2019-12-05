This PowerShell script is intended for use with Zabbix 3.x and higher. This script must be placed in the C:\Scripts folder on 
each server. Change the $path variable to indicate the Scheduled Tasks subfolder to be processed as 
"\nameFolder\","\nameFolder2\subfolder\" 

Use "Get-ScheduledTask -TaskPath" to view the paths of the Scheduled Tasks. A Zabbix Agent Config file has been added, for 
your convenience. Change the operational Zabbix configuration file, to reflect the values with this file.

Items: Task Last Result (Status for each tasks), Task Last Run Time, Task Next Run time
Discovery: All tasks Active or Running
Triggers: [AVERAGE] => Last Result of tasks FAILED

Installation:
- Import template "zbx_template_DiscoverScheduledTasks.xml" into Zabbix
- Reconfigure the Zabbix agent on your host
- Disable (add # at the beginning of the line) the following line in the Zabbix agent configuration file:
  - Hostname=fra2vwapp01.ascio.loc
- Add the following line to your Zabbix agent configuration file:
  - HostnameItem=system.hostname
  - EnableRemoteCommands=1
  - UnsafeUserParameters=1
  - UserParameter=TaskSchedulerMonitoring[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\DiscoverScheduledTasks.ps1" "$1" "$2"
- Copy DiscoverScheduledTasks.ps1 in C:\Scripts
- In powershell script change $path variable for subfolders. By default: $path = "\"

Timeout=(3-30) Adjust with your server performance (and don't forget in server.conf on zabbix server: timeout specifies how long we 
wait for agent, SNMP device or external check (in seconds) so adjust this as well)
