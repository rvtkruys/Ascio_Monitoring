# IIS Monitoring (with low-level discovery)

> Adjusted by Roland van 't Kruijs (05/12/2019)

> Originally created by Diego Cavalcante (10/02/2017) and improved by Ilias Aidar (24/09/2019)

When monitoring IIS Server Role, the following collections are monitored:

**ITEMS**
* \Web Service(_Total)\Bytes Received/sec
* \Web Service(_Total)\Bytes Sent/sec
* \Web Service(_Total)\Bytes Total/sec
* \Web Service(_Total)\Current Anonymous Users
* \Web Service(_Total)\Current Connections
* \Web Service(_Total)\Current NonAnonymous Users
* \Web Service(_Total)\Get Requests/sec
* \Web Service(_Total)\Post Requests/sec
* \Web Service(_Total)\Put Requests/sec
* \Web Service Cache\Current Files Cached
* \Web Service Cache\Current Metadata Cached
* \Web Service Cache\Current URIs Cached
* \Web Service Cache\File Cache Hits %
* \Web Service Cache\Metadata Cache Hits
* \Web Service Cache\URI Cache Hits %
* \SMTP Server(_Total)\Remote Queue Length
* Application Pools
* Sites
* Port 80 and 443

**TRIGGERS**
* Application Pool Status
* Site Status
* Port Status
* SMTP Server Remote Queue Length

## 1. HOST PREPARATION
Monitoring itself requires some adjustments to be made to the host prior to data collection. There is a default directory, that I use for Scripts.
```
Scripts: C:\Scripts
```
And there is an adjustment needed in the UserParameters section of the zabbix_agentd.conf file.
```
# This is a configuration file for Zabbix agent service (Windows)
# To get more information about Zabbix, visit http://www.zabbix.com

############ ADVANCED PARAMETERS #################

####### USER-DEFINED MONITORED PARAMETERS #######

### Option: UnsafeUserParameters
#	Allow all characters to be passed in arguments to user-defined parameters.
#	The following characters are not allowed:
#	\ ' " ` * ? [ ] { } ~ $ ! & ; ( ) < > | # @
#	Additionally, newline characters are not allowed.
#	0 - do not allow
#	1 - allow
#
# Mandatory: no
# Range: 0-1
# Default:
# UnsafeUserParameters=0

UnsafeUserParameters=1

### Option: UserParameter
#	User-defined parameter to monitor. There can be several user-defined parameters.
#	Format: UserParameter=<key>,<shell command>
#
# Mandatory: no
# Default:
# UserParameter=

UserParameter=apppool.discovery,powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\get_apppool.ps1"
UserParameter=apppool.state[*],powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\get_apppoolstate.ps1" "$1"
UserParameter=site.discovery,powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\get_sites.ps1"
UserParameter=site.state[*],powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\get_sitestate.ps1" "$1"
```
**NOTE:** Adjust according to your environment, within Host zabbix_agentd.conf, adjust the parameter: Include = and point to
directory where it will contain your .conf files with the UserParameters.

## 2. INITIAL REQUIREMENTS
* If you have already done the above procedure on the Host, disregard and skip to the next request.
* Put get_apppool.ps1, get_apppoolstate.ps1, get_sites.ps1 and get_sitestate.ps1 in the Scripts directory.
* Restart Zabbix Agent on the Host.

## 3. TEMPLATE
Import the Template - *zbx_template_IISMonitoring.xml* into your Zabbix Frontend.
* Associate the Template with the monitored Host and wait for the collection.
* Adjust the collection intervals, History retention period and Trend of items according to your environment.

**NOTE:** If data is not collected, use and abuse zabbix_get to validate data collection.