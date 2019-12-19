# Installing & Configuring the Octopus Tentacle

> Created by Roland van 't Kruijs (19/12/2019)

WARNING: DO NOT USE THIS SCRIPT IN THE PRODUCTION. IT CONTAINS FAKE REFERENCES, WHICH MUST BE ADJUSTED FIRST.

This script will download the installation file from Octopus Downloads and install it according to the specifications of the Octopus environment. Once installed, the script will configure and connect the Octopus Tentacle service to the Ascio Octopus console. Once the installation process is completed, all temporary settings to gain access to the Internet will be reversed.

Copy the script in C:\Scripts

**VALUES**
* $serverThumbprint
* $serverUri
* $tentacleInstallApiKey

**INPUT VALUES**
* Role ID 
* Environment ID

## 1. HOST PREPARATION
Copy the script into the designated folder. Adjust the values to match against your Octopus environment. Run this script by using an administrative account on the server. Provide the Role ID and Environment ID in all caps and start the installation. This process takes less than one minute to complete.
```
Scripts: C:\Scripts
```