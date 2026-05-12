# Aggregate Azure consumption costs by resource group for the last 30 days
<#
.SYNOPSIS
    Summarizes Azure consumption by resource group for the past N days.
.PARAMETER SubscriptionId
    The subscription to query. If not specified, uses current context.
.PARAMETER DaysBack
    Number of days back from today to summarize (default 30).
.EXAMPLE
    Get-AzCostSummary -SubscriptionId "00000000-0000-0000-0000-000000000000" -DaysBack 15
.EXAMPLE
    Get-AzCostSummary -DaysBack 60
.NOTES
    Requires Az.Accounts and Az.CostManagement modules.
#>
function Get-AzCostSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)][string]$SubscriptionId,
        [Parameter(Mandatory = $false)][int]$DaysBack = 30
    )
    # Ensure you are authenticated
    if (-not (Get-AzContext)) {
        Write-Verbose "Not logged into Azure. Logging in..."
        Connect-AzAccount -ErrorAction Stop
    }
    # Set context if SubscriptionId is provided
    if ($SubscriptionId) {
        Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
    }
    $endDate   = (Get-Date).ToString('yyyy-MM-dd')
    $startDate = (Get-Date).AddDays(-$DaysBack).ToString('yyyy-MM-dd')
    Write-Verbose "Getting Azure cost data from $startDate to $endDate..."
    $usages = Get-AzConsumptionUsageDetail -StartDate $startDate -EndDate $endDate
    if (-not $usages) {
        Write-Warning "No consumption data found for specified period."
        return
    }
    $summary = $usages | Group-Object -Property ResourceGroup | ForEach-Object {
        [PSCustomObject]@{
            ResourceGroup = $_.Name
            TotalCost     = ($_.Group | Measure-Object -Property PretaxCost -Sum).Sum
        }
    }
    $summary | Sort-Object TotalCost -Descending | Format-Table -AutoSize
}
