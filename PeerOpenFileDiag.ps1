# A script to retrieve detailed processor and memory information as well as the entire open file list from a remote file server.
#
# Requirements: This script must be run under an account with local admin rights on the remote file server.
#
# 
# Usage:
# .\PeerOpenFileDiag.ps1 -RemoteSystemName <NAME OR IP ADDRESS OF FILE SERVER> -LogFile <PATH TO LOG FILE TO WHICH THE SCRIPT WILL APPEND>
#
# Version: 002
# Author: Matt Marsala

param
(
    [Parameter(Mandatory = $true)]
    [String]
    $RemoteSystemName,

    [Parameter(Mandatory = $true)]
    [String]
    $LogFile
)

"" | Out-File $LogFile -Append
"====================================================================================" | Out-File $LogFile -Append
"" | Out-File $LogFile -Append

"Open File Diagnostics Script v002" | Out-File $LogFile -Append

"PowerShell Version is " + $PSVersionTable.PSVersion | Out-File $LogFile -Append

"Local System: " + $env:COMPUTERNAME | Out-File $LogFile -Append
"Remote System: " + $RemoteSystemName | Out-File $LogFile -Append
"Log Location: " + $LogFile | Out-File $LogFile -Append

"" | Out-File $LogFile -Append

"Local OS Info" | Out-File $LogFile -Append

"OS: " + $env:OS | Out-File $LogFile -Append

Get-WmiObject Win32_OperatingSystem | Out-File $LogFile -Append

"" | Out-File $LogFile -Append

"Processor Info" | Out-File $LogFile -Append

Get-WmiObject –class Win32_processor | select * | Out-File $LogFile -Append

"" | Out-File $LogFile -Append

"Total Local Memory" | Out-File $LogFile -Append

Get-WmiObject CIM_PhysicalMemory | Measure-Object -Property capacity -sum | % {[math]::round(($_.sum / 1GB),2)} | Out-File $LogFile -Append

"Local Memory Info" | Out-File $LogFile -Append

Get-WmiObject CIM_PhysicalMemory | Out-File $LogFile -Append


"" | Out-File $LogFile -Append

"Current Run Started at:" | Out-File $LogFile -Append
Get-Date | Out-File $LogFile -Append

$sw = New-Object System.Diagnostics.Stopwatch
$sw.Start()

openfiles /query /S $RemoteSystemName /fo CSV /v | Out-File $LogFile -Append

$sw.Stop()

"Open File Diagnostics Complete at:" | Out-File $LogFile -Append
Get-Date | Out-File $LogFile -Append

"Elapsed Time:" | Out-File $LogFile -Append
$elHours = $sw.Elapsed.Hours
$elMinutes = $sw.Elapsed.Minutes
$elSeconds = $sw.Elapsed.Seconds
"$elHours hours, $elMinutes minutes, $elSeconds seconds" | Out-File $LogFile -Append