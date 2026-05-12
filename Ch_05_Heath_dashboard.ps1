$health = @{}  # {ServerName = @{Success=0; Fail=0; Retries=0; Status='Active'}}
$pool = [runspacefactory]::CreateRunspacePool(1, 20)
$scriptBlock = {
    param($Server, $HealthRef)  
    $health = $HealthRef[$Server]
    if ($health.SuccessRate -lt 0.7 -and $health.Retries -ge 3) {
        $health.Status = 'Quarantined'
        return @{Server=$Server; Status='QUARANTINED'; Reason='LowSuccess'}
    }    
    # Exponential backoff
    if ($health.Retries -gt 0) {
        Start-Sleep ( [math]::Pow(2, $health.Retries) )
    }    
    try {
        # Your actual remoting command here
        $result = Invoke-Command -ComputerName $Server -ScriptBlock { ... }
        $health.Success++
        $health.Status = 'Healthy'
    }
    catch {
        $health.Fail++
        $health.Retries++
        $health.Status = if ($health.Retries -ge 3) { 'Flaky' } else { 'Recovering' }
    }    
    $health.SuccessRate = $health.Success / ($health.Success + $health.Fail)
}
# Live dashboard every 30s
$timer = [System.Diagnostics.Stopwatch]::StartNew()
while ($tasks.ActiveCount -gt 0) {
    Clear-Host
    Write-Host "Healthy: $(($health.Values | ? Status -eq 'Healthy').Count) | Flaky: $(($health.Values | ? Status -eq 'Flaky').Count) | Quarantined: $(($health.Values | ? Status -eq 'Quarantined').Count)"
    Write-Host "ETA Impact: +$([math]::Round(($health.Values | ? Status -ne 'Healthy').Count * 2.5)) minutes"
    Start-Sleep 30
}
