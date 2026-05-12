# Step 1: Define the workspace target
$workspaceId = "/subscriptions/your-sub-id/resourceGroups/your-rg/providers/Microsoft.OperationalInsights/workspaces/Production-Logs"
# Step 2: Define the KQL as a standard string 
# This query uses AI-suggested logic to identify statistical outliers in error logs
$kql = "exceptions | where timestamp > ago(1d) | make-series count() on timestamp from ago(1d) to now() step 1h by operation_Name | extend (anom, score, baseline) = series_decompose_anomaly(count_, 1.5) | mv-expand timestamp, count_, anom, score, baseline | where anom != 0"
# Step 3: Execute the query via the Az module
$result = Invoke-AzOperationalInsightsQuery -WorkspaceId $workspaceId -Query $kql
# Step 4: Conditional reporting and exporting
if ($result.Results.Count -gt 0) {
    # Sort by the AI's anomaly score to find the most significant spikes 
    $result.Results | Sort-Object score -Descending | Select-Object timestamp, count_, score -First 10 | Export-Csv "exception_anomalies.csv" -NoTypeInformation
    Write-Host "Alert: Significant anomalies detected. Data exported to exceptions_anomalies.csv" -ForegroundColor Red
} else {
    Write-Host "Monitoring complete: No significant deviations from baseline detected." -ForegroundColor Green
}
