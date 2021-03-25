<# 
.SYNOPSIS
LogXenAppSessions.ps1 - Log current Citrix XenApp sessions

.DESCRIPTION 
Log current Citrix XenApp sessions to a CSV file, load CSV file, remove duplicates, repeat

.OUTPUTS
Results are saved at each run to a dated CSV file. That file is loaded and duplicate values are removed.

.EXAMPLE
./LogXenAppSessions.ps1
This script is designed to run as a scheduled task. Change the variables in the GLOBALS section and execute the script.

.NOTES
Written by Brian D. Arnold

Change Log:
2018-08-30 Initial version
2021-03-15 Cleanup formatting and comments
2021-03-24 Added alternative commands for CVAD
#>

###############
##### PRE #####
###############

if ( (Get-PSSnapin -Name Citrix* -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PsSnapin Citrix*
}

###################
##### GLOBALS #####
###################

# Date variables
# Today
$prefix = Get-Date -Format "yyyy-MM-dd dddd"
# Date of next Saturday
$weekending = $Date = @(@(0..7) | % {$(Get-Date).AddDays($_)} | WHERE {$_.DayOfWeek -ieq "Saturday"})[0]
$datetime = Get-Date -Format G

# CSV Locations
# Daily
$Outfile1 = "\\SERVER\SHARE\Daily\XenApp Sessions $prefix.csv"
# Weekly
$Outfile2 = "\\SERVER\SHARE\Weekly\XenApp Sessions Week Ending $($weekending.ToString("dddd yyyy-MM-dd")).csv"
# Counts
$Outfile3 = "\\SERVER\SHARE\Counts\XenApp Session Counts $prefix.csv"

################
##### MAIN #####
################

#Get active sessions and export to CSV
# Daily XenApp
Get-XASession | WHERE {$_.State -eq "Active"} | Select @{Name="Application";Expression={$_.BrowserName}},SessionId,@{Name="User";Expression={$_.AccountName}},LogOnTime,ClientName,State | Export-Csv $Outfile1 -NoTypeInformation -Append
# Daily CVAD
# Get-BrokerSession -MaxRecordCount 20000 | WHERE {$_.SessionState -eq "Active" -and $_.SessionType -eq "Application"} | Select @{Name="Application";Expression={$_.LaunchedViaPublishedName}},SessionKey,UserName,StartTime,ClientName,SessionState | Export-Csv $Outfile1 -NoTypeInformation -Append
# Weekly XenApp
Get-XASession | WHERE {$_.State -eq "Active"} | Select @{Name="Application";Expression={$_.BrowserName}},SessionId,@{Name="User";Expression={$_.AccountName}},LogOnTime,ClientName,State | Export-Csv $Outfile2 -NoTypeInformation -Append
# Weekly CVAD
# Get-BrokerSession -MaxRecordCount 20000 | WHERE {$_.SessionState -eq "Active" -and $_.SessionType -eq "Application"} | Select @{Name="Application";Expression={$_.LaunchedViaPublishedName}},SessionKey,UserName,StartTime,ClientName,SessionState | Export-Csv $Outfile2 -NoTypeInformation -Append
# Counts XenApp
$count = (Get-XASession | WHERE {$_.State -eq "Active"}).count
# Counts CVAD
# $count = (Get-BrokerSession -MaxRecordCount 20000 | WHERE {$_.SessionState -eq "Active" -and $_.SessionType -eq "Application"}).count
$summary = New-Object psobject
$summary | Add-Member -MemberType NoteProperty -name Users -Value $count
$summary | Add-Member -MemberType NoteProperty -name Date-Time -Value $datetime
$summary | Export-Csv $Outfile3 -NoTypeInformation -Append

# Remove duplicate rows on CSV
# Daily
$dup1 = Import-Csv $Outfile1 | Sort-Object * -Unique
$dup1 | Export-Csv $Outfile1 -NoTypeInformation -Force
# Weekly
$dup2 = Import-Csv $Outfile2 | Sort-Object * -Unique
$dup2 | Export-Csv $Outfile2 -NoTypeInformation -Force
