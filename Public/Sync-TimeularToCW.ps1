function Sync-TimeularToCW {
    [CmdletBinding()]

    Param (

        [Parameter(Mandatory = $true, Position = 0)]
        [string]$TimeularApiKey,

        [PoshBot.FromConfig()]
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$TimeularApiSecret,

        [Parameter(Mandatory = $true, Position = 2)]
        [int]$SyncTimeFrame,

        [Parameter(Mandatory = $false, Position = 3)]
        [string]$Note
    )

# Get Token
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

$body = "{`n  `"apiKey`"    : `"$TimeularApiKey`",`n  `"apiSecret`" : `"$TimeularApiSecret`"`n}"

$response = Invoke-RestMethod 'https://api.timeular.com/api/v3/developer/sign-in' -Method 'POST' -Headers $headers -Body $body
$bearer = $response.token

#Get Activity Names and IDs

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $bearer")

$global:ActivityResponse = Invoke-RestMethod 'https://api.timeular.com/api/v3/activities' -Method 'GET' -Headers $headers
$global:ActivityResponse | ConvertTo-Json

$global:ActivityIDs = @{}
foreach ($Activity in $ActivityResponse.activities) {
    $ActivityIDs.Add($Activity.id,$Activity.name)
}

$ActivityIDs

#Get Time Entries from Timeular

$now = Get-Date 
$then = $now.AddHours(-$SyncTimeFrame).ToString("yyyy-MM-ddTHH:mm:ss.fff")
$now = $now.ToString("yyyy-MM-ddTHH:mm:ss.fff")


$URI = "https://api.timeular.com/api/v3/time-entries/$($then)/$($now)"

$global:TimeResponse = Invoke-RestMethod $URI -Method 'GET' -Headers $headers
$global:TimeResponse | ConvertTo-Json -Depth 6


#Match the ActivityID to the Activity and create payload for JSON
foreach ($timeentry in $TimeResponse.timeEntries) {
    foreach ($actID in $ActivityIDs.GetEnumerator() | where-object { $timeentry.activityId -eq $_.name }) {
        Write-Host $actID.name
        $ticketnumber = $actID.value
        Write-Host $ticketnumber
    }
     #Write-Host $timeentry.activityId
     $jsonpayload = @"
     {
     "Activity ID": $($timeentry.activityId),
     "Ticket:" $ticketnumber,
     "Start Time": $($timeentry.duration.startedAt),
     "End Time": $($timeentry.duration.stoppedAt),
     "Note": $($timeentry.note.text)
    }
"@

     Write-Host $jsonpayload
}

}
