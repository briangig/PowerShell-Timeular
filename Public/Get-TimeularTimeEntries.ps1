function Get-TimeularTimeEntries {
    [CmdletBinding()]

    Param (
    
        [Parameter(Mandatory = $true)]
        [switch]$TimeFrame,
        
        [Parameter(Mandatory = $false)]
        [switch]$AutoConnect
    )

    $VerbosePrefix = "Get-TimeularTimeEntries:"

    $Response = Invoke-TimeularApiCall -Endpoint '/time-entries' -Body $Body -Method 'GET' -AutoConnect:$AutoConnect
    $Response = $Response.message

    if ($null -eq $Response) {
        $false
    } else {
        $ReturnObject = "" | Select-Object `
            ActivityId, Name, Color, Integration, `
            StartTime, `
            Note, Tag, Mention

        $ReturnObject.ActivityId = $Response.activity.id
        $ReturnObject.Name = $Response.activity.name
        $ReturnObject.Color = $Response.activity.color
        $ReturnObject.Integration = $Response.activity.integration

        $ReturnObject.StartTime = [datetime]$Response.startedAt

        $ReturnObject.Note = $Response.note.text
        $ReturnObject.Tag = $Response.note.tags
        $ReturnObject.Mention = $Response.note.mentions

        $ReturnObject
    }
}