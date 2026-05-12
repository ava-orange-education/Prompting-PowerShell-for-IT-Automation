# AI-generated: Daily Event Monitor
$start = (Get-Date).AddDays(-1).ToUniversalTime()
$end = (Get-Date).ToUniversalTime()
$criticalEvents = @()

$logs = Get-AzLog -StartTime $start -EndTime $end | Where-Object {
    ($_.EventName -match "Delete|Scale" -and $_.ResourceId -match "tag/Production") -or
    ($_.EventName -eq "AuthenticationFailed" -and $_.CallerIpAddress -match "\d+\.\d+") -or
    $_.Category -eq "Security"
}

foreach ($log in $logs) {
    $criticalEvents += [PSCustomObject]@{
        Time = $log.EventTimestamp
        Caller = $log.Caller
        Resource = ($log.ResourceId -split '/')[-1]
        Event = $log.EventName
        Severity = $log.Level
    }
}

$htmlReport = $criticalEvents | ConvertTo-Html -Property * -Head "<style>table {border-collapse:collapse} th,td {border:1px solid #ddd;padding:8px}</style>"
if ($criticalEvents.Count -gt 5) {
    Send-MailMessage -To "ops@contoso.com" -From "monitor@contoso.com" -Subject "Critical Events Detected ($($criticalEvents.Count))" -Body $htmlReport -BodyAsHtml -SmtpServer "smtp.contoso.com"
}
