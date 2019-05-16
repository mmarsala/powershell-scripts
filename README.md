# Sample PowerShell Scripts

A growing repository of simple PowerShell scripts to use in various networking and storage administration tasks.

## Examples
`GetLocalGroupsAndUsers.ps1` - A script to retrieve local users and groups from a remote file server
```
.\GetLocalGroupsAndUsers.ps1 -fileserver <NAME, IP, or FQDN OF FILE SERVER>
```
-------------------------
`GetDetailedFileAndFolderInfo.ps1` - A script to retrieve detailed information on a specified file or folder. Information includes reparse details and alternate data streams. If the script is pointed at a folder, it will return information on the root folder as well as for all immediate children.
```
.\GetDetailedFileAndFolderInfo.ps1 -path <LOCAL OR REMOTE PATH TO A FILE OR FOLDER>
```
-------------------------
`PeerOpenFileDiag.ps1` - A script to retrieve detailed processor and memory information as well as the entire open file list from a remote file server.
```
.\PeerOpenFileDiag.ps1 -RemoteSystemName <NAME OR IP ADDRESS OF FILE SERVER> -LogFile <PATH TO LOG FILE TO WHICH THE SCRIPT WILL APPEND>
```

## Disclaimer
This repository does not represent an official repository for Peer Software or Microsoft. All code and information in this repository is provided as is.