# Dynamic targeting with safety gates
$targets = Get-AzVM | Where-Object { 
    $_.Tags.Environment -eq 'Prod' -and 
    $_.Tags.Tier -eq 'Web' -and 
    $_.Tags.IsDR -ne $true 
}
# Pre-flight validation
$validation = foreach ($vm in $targets) {
    $status = Invoke-Command -ComputerName $vm.Name -ScriptBlock {
        $cert = Get-ChildItem Cert:\LocalMachine\My | Where Thumbprint -eq 'EXPECTED'
        [PSCustomObject]@{ VM=$env:COMPUTERNAME; Valid=$cert.Count -eq 1; Thumbprint=$cert.Thumbprint }
    }
    $status
}
