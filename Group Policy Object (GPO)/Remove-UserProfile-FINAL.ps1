# Creator: TheHumbleBuzz
# Company: Place Holder
# Date: 8/1/2024


# Specify the OU you want to query
$OU = 'OU=OU2,OU=OU1,DC=YOURDOMAIN,DC=COM'

# Get a list of users from the specified OU
$users = Get-ADUser -Filter * -SearchBase $OU | Select-Object DistinguishedName, Name, UserPrincipalName, sAMAccountName

# Create a log file
$logFile = "C:\ScriptLog.txt"

# Iterate through each user and remove their profile
foreach ($user in $users) {
    $profilePath = "C:\Users\$($user.sAMAccountName)"
    if (Test-Path $profilePath) {
        Remove-Item -Path $profilePath -Recurse -Force
        Write-Host "Removed profile for $($user.sAMAccountName)"
    } else {
        Write-Host "Profile not found for $($user.sAMAccountName)"
    }
}

Write-Host "Log file created at $logFile"
