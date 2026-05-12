$pool = [runspacefactory]::CreateRunspacePool(1, 12)
$pool.Open()
$tasks = $servers | ForEach-Object {
    $ps = [powershell]::Create().AddScript({
        # Safety check on current disk queue length
        if ((Get-WmiObject Win32_LogicalDisk).CurrentCommandQueueLength -gt 20) {
            return @{ Host = $env:COMPUTERNAME; Status = 'Skipped - High IO' }
        }     
        # Coordinated cleanup logic here per server
    }).AddParameter('Server', $_)
    $ps.RunspacePool = $pool
    @{ PowerShell = $ps; Handle = $ps.BeginInvoke() }
}
