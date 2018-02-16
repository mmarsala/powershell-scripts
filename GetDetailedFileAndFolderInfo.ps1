# Script to get detailed file and folder info for a path. Information includes reparse and stream details.
# If the path points to a folder, information for all immediate children will also be reported.
#
# Requirements: This script must be run under an account with local admin rights on the remote file server.
#
# 
# Usage:
# .\GetDetailedFileAndFolderInfo.ps1 -path <Path to file or folder>
#
# Version: 001
# Author: Matt Marsala

param
(
    [Parameter(Mandatory = $true)]
    [String]
    $path
)

$item = Get-Item $path

# Build a list of streams for the root file or folder
$rootStreamInfo = Get-Item $path -stream *
$streamObjs=@()

foreach ($streamItem in $rootStreamInfo) {
    $streamInfo = @{"StreamName"=$streamItem.Stream; "StreamLength"=$streamItem.Length};
    $streamObj = New-Object PSObject -Property $streamInfo
}

# Used to get deailed reparse point information
$fsutil = "$Env:WinDir\system32\fsutil.exe"

# Check if the root path is a file or folder
if ($item.PsIsContainer) {

    Write-Host "=====Root Directory [$path]====="

    # If root path is a folder, grab info about the folder and dump it to the console (including list of root streams from above)
    $folderDetails = @{"RootDirectory"=$path; "StreamInfo"=$streamObjs; "Size"=$item.Length; "Attributes"=$item.Attributes;  `
         "Target"=$item.Target; "LinkType"=$item.LinkType; "Mode"=$item.Mode;  `
         "LastModTime"=$item.LastWriteTime; "LastAccessedTime"=$item.LastAccessTime; "CreateTime"=$item.CreationTime};

    $folderDetailsObj = New-Object PSObject -Property $folderDetails

    $folderDetailsObj|fl -Property "RootDirectory", "Size", "Attributes", "LinkType", "Target", "Mode", "LastModTime", "LastAccessedTime", "CreateTime", "StreamInfo"

    # Use fsutil to get more in-depth information on any potential reparse
    # TODO figure out a better way to format the output of fsutil. For now, just dump its raw text to the console.
    Write-Host "==========Detailed Reparse Info for Root Directory [$path]=========="
    &$fsutil reparsepoint query $path

    # Extra spacing to make it easier to match fsutil output with root
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    
    # Then iterate through all direct children
    $children = Get-ChildItem -path $path

    foreach ($child in $children) {

        $childPath = "$path\$child"

        # Build a list of streams for the current child
        $childSteam = Get-Item $child.PSPath -stream *
        $streamObjs=@()

        foreach ($streamItem in $childSteam) {
            $streamInfo = @{"StreamName"=$streamItem.Stream; "StreamLength"=$streamItem.Length};
            $streamObj = New-Object PSObject -Property $streamInfo
            $streamObjs+=$streamObj
        }

        # Check if current child is a file or folder, grab its info and dump to the console (including a list of its streams)
        if ($child.PsIsContainer) {
            Write-Host "=====Child Directory [$childPath]====="

            $childFolderDetails = @{"ChildDirectory"=$child; "StreamInfo"=$streamObjs; "Size"=$child.Length; "Attributes"=$child.Attributes;  `
             "Target"=$child.Target; "LinkType"=$child.LinkType; "Mode"=$child.Mode;  `
             "LastModTime"=$child.LastWriteTime; "LastAccessedTime"=$child.LastAccessTime; "CreateTime"=$child.CreationTime};

            $childFolderDetailsObj = New-Object PSObject -Property $childFolderDetails

            $childFolderDetailsObj|fl -Property "ChildDirectory", "Size", "Attributes", "LinkType", "Target", "Mode", "LastModTime","LastAccessedTime", "CreateTime", "StreamInfo"

            # Use fsutil to get more in-depth information on any potential reparse
            # TODO figure out a better way to format the output of fsutil. For now, just dump its raw text to the console.
            Write-Host "==========Detailed Reparse Info for Child Directrory [$childPath]=========="
            &$fsutil reparsepoint query $childPath

        } else {
            Write-Host "=====Child File [$childPath]====="

             $childFileDetails = @{"ChildFile"=$child; "StreamInfo"=$streamObjs; "Size"=$child.Length; "Attributes"=$child.Attributes;  `
            "Target"=$child.Target; "LinkType"=$child.LinkType; "Mode"=$child.Mode; "Extension"=$child.Extension; `
             "LastModTime"=$child.LastWriteTime; "LastAccessedTime"=$child.LastAccessTime; "CreateTime"=$child.CreationTime; `
             "VersionInfo"=$child.VersionInfo};

            $childFileDetailsObj = New-Object PSObject -Property $childFileDetails

            $childFileDetailsObj|fl -Property "ChildFile", "Size", "Attributes", "Extension", "VersionInfo", "LinkType", "Target", "Mode", "LastModTime", "LastAccessedTime", "CreateTime",  "StreamInfo"

            # Use fsutil to get more in-depth information on any potential reparse
            # TODO figure out a better way to format the output of fsutil. For now, just dump its raw text to the console.
            Write-Host "==========Detailed Reparse Info for Child File [$childPath]=========="
            &$fsutil reparsepoint query $childPath
        }

        # Extra spacing to make it easier to match fsutil output with a child
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host ""

    }

} else {

    # If root path is a file, grab info about the file and dump it to the console (including list of root streams from above)

    $fileDetails = @{"File"=$path; "StreamInfo"=$streamObjs; "Size"=$item.Length; "Attributes"=$item.Attributes;  `
         "Target"=$item.Target; "LinkType"=$item.LinkType; "Mode"=$item.Mode; "Extension"=$item.Extension; `
         "LastModTime"=$item.LastWriteTime; "LastAccessedTime"=$item.LastAccessTime; "CreateTime"=$item.CreationTime; `
         "VersionInfo"=$item.VersionInfo};

    $fileDetailsObj = New-Object PSObject -Property $fileDetails

    $fileDetailsObj|fl -Property "Path", "Size", "Attributes","Extension", "VersionInfo", "LinkType", "Target", "Mode", "LastModTime","LastAccessedTime", "CreateTime", "StreamInfo"

    # Use fsutil to get more in-depth information on any potential reparse
    # TODO figure out a better way to format the output of fsutil. For now, just dump its raw text to the console.
    Write-Host "=====Detailed Reparse Info for Root File [$path]====="
    &$fsutil reparsepoint query $path
}