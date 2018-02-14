# Script to get the local groups and users (with their corresponding SIDs) from a remote file server.
#
# Requirements: This script must be run under an account with local admin rights on the remote file server.
#
# Bonus: Running this against a domain controller returns domain user and group information.
# 
# Usage:
# .\GetLocalGroupsAndUsers.ps1 -fileserver <NAME, IP, or FQDN OF FILE SERVER>
#
# Version: 001
# Author: Matt Marsala

param
(
    [Parameter(Mandatory = $true)]
    [String]
    $fileserver
)

Write-Host "Connecting to $fileserver..."

# Connect to remote file server using ADSI accelerator
$adsi = [ADSI]"WinNT://$fileserver"

# Get a list of all local groups
$groups = $adsi.Children | where {$_.SchemaClassName -eq  'group'}

Write-Host "======Local Groups======"

# For each group, print its name, Sid, and a list of members
foreach ($group in $groups) {
    $groupname = $group.Name

    Write-Host "Local Group:" $groupname
    Write-Host "Sid:" (New-Object System.Security.Principal.SecurityIdentifier($group.ObjectSID[0],0)).value
    Write-Host "Members:"

    # Make sure that the group name is coming back correctly
    If ([string]::IsNullOrEmpty($groupname)) {
        Write-Host "   Unable to query local group members due to null or empty group name"
        Write-Host

    } else {

        $adsigroup = "$fileserver/$groupname"

        $members = $([ADSI]"WinNT://$adsigroup").psbase.Invoke('Members')

        # Convert members to appropriate Domain\User or Localserver\User format
        foreach ($member in $members) {
            $adspath = ($member.GetType().InvokeMember('ADspath', 'GetProperty', $null, $member, $null)).Replace('WinNT://', '').Replace('/', '\')
            $username = ($member.GetType().InvokeMember('Name', 'GetProperty', $null, $member, $null))

            if ($adspath -match "$fileserver") {
                Write-Host "   $fileserver\$username"
            } else {
                Write-Host "   $adspath"
            }
        }

        Write-Host
    }
}

Write-Host "======Local Users======"

# Get a list of all local users
$users = $adsi.Children | where {$_.SchemaClassName -eq  'user'}

# For each user, print its name and Sid
foreach ($user in $users) {
    Write-Host "Local User:" $user.Name
    Write-Host "Sid:" (New-Object System.Security.Principal.SecurityIdentifier($user.ObjectSID[0],0)).value

    Write-Host
}