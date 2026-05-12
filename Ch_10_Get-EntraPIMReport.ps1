# Generate PIM violations report matching Get-ADCleanupReport
function Get-EntraPIMReport {
[CmdletBinding()]
param([int]$DaysThreshold = 30)
. $PSScriptRoot/../Private/Log-AuditEvent.ps1
Get-MgRoleManagementDirectoryRoleAssignmentScheduleInstance |
Where-Object { $_.EndDateTime -lt (Get-Date).AddDays(-$DaysThreshold) } |
ForEach-Object {
    Log-AuditEvent -Event "PIMViolation" -Data $_.PrincipalId
    [PSCustomObject]@{
        Account = $_.PrincipalId
        DaysIdle = [math]::Round((New-TimeSpan $_.EndDateTime).TotalDays)
        Role = $_.RoleDefinitionId
    }
}
}
