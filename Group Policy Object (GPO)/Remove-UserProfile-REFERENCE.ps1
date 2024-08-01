
I have created script for cleanup. After doing significant research I found the following:

GPO for deleting old users does nothing due to MS breaking stuff

Get-CimInstance win32_userprofile Last user time is updated by Windows updates. Along with the WIM equivalent.

In the end I created a script that checked last write time of every folder under C:\Users\<Username> (Excluding NTUSER.DAT) and took the newest value and compared that. Script below.

## Script to delete user profiles older than 90 days.##

# Define log file

$Logpath = "C:\Logs\ScriptLogs"

$Logfile = "User Profile Cleanup.log"

$Logfullpath = $Logpath + $Logfile

# Create folder for log files if it does not already exist

if (-not (test-path -path $Logpath)) {

mkdir $Logpath | Out-Null

write-output "Log directory '$Logpath' does not exist, creating..."

}

# Build list of User profiles that are older than 90 days and exclude relevant profiles

# Get current date and time to compare against

$Current_Date = (Get-Date).AddDays(-90)

$Real_Date = Get-Date

# Generate list of Users

$Users = Get-ChildItem -path C:\Users | Where-Object {$_.Name -notlike "Public"}

$Userstoclear = @()

# Get each folder of user profile and check last write time.

foreach ($User in $Users) {

$UserFiles = Get-ChildItem -path "C:\Users\$User" -force | Where-Object {$_.Name -notlike "NTUSER.DAT*"}

#Sets Users last write time to 0 so it doesn't carry value over

$UserLastWriteTime = $null

# Checks the last write time of each folder in Users Folders and stores the newest value.

foreach ($File in $UserFiles) {

if ($File.LastWriteTime -gt $UserLastWriteTime) {

$UserLastWriteTime = $File.LastWriteTime

}

}

# To assist with troubleshooting

Write-Output $User.Name "Last Use time is $UserLastWriteTime and the boundary is $Current_Date"

# Check the time to see if it is newer than 90days.

if ($UserLastWriteTime -lt $Current_Date) {

$Userstoclear += "C:\Users\$User"

Write-Output "Adding to deletion list"

}

else {

Write-Output "Not Adding to deletion List"

}

}

# Adding to log

add-content -path $Logfullpath "$Real_Date : The following users have been detected as not being used for 90 days $Userstoclear"

Write-Output "$Real_Date : The following users have been detected as not being used for 90 days" $Userstoclear

# List of profile paths that should be excluded from being deleted.

$Excluded_Profiles = ""

# Example profile paths for exclusion: "C:\Users\Administrator""

# Query all user profiles then filter out loaded profile and built-in computer profiles along with excluded profiles and by last use date.

$UserProfiles = Get-CimInstance win32_userprofile | Where {$_.LocalPath -notin $Excluded_Profiles -and

!$_.Loaded -and

!$_.Special -and

$_.LocalPath -in $Userstoclear

}

# Adding to log

add-content -path $Logfullpath "$Real_Date : Filtering out profiles that should not be deleted. Updated List:" $UserProfiles.LocalPath

Write-Output "$Real_Date : Filtering out profiles that should not be deleted. Updated List:" $UserProfiles.LocalPath

# Delete user profiles in list.

# Only run if statement if it has picked up userprofiles that meet the criteria

if ($UserProfiles -ne $null) {

Foreach ($_ in $UserProfiles) {

add-content -path $Logfullpath "$Real_Date : Deleting Userprofile for:$($_.LocalPath)"

write-host "$Real_Date : Deleting Userprofile for $($_.LocalPath)"

## Uncomment below when you want to use this.

#Remove-CimInstance $_

}

}

Else {

add-content -path $Logfullpath "$Real_Date : userprofile clean-up was run but no user profiles were detected that met the required criteria"

write-host "No Userprofiles detected that meet the deletion criteria"

}
