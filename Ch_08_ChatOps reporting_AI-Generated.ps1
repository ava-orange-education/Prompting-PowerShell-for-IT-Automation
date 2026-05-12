# Scenario: Reporting a surge in failed logins detected by KQL
$alertData = Invoke-AzOperationalInsightsQuery -WorkspaceId $id -Query $kqlQuery
# The AI-Generated Narrative (Simplified for portability)
$prompt = "Summarize these 50 failed login events. Identify if they originate from one IP or multiple, and suggest an Az PowerShell command to block the source."
$summary = Get-AIAnalysis -InputData $alertData -Prompt $prompt 
# Sending to Teams via Webhook
$payload = @{ text = "🚨 **Security Alert Summary**: $summary" } | ConvertTo-Json
Invoke-RestMethod -Uri $teamsWebhookUrl -Method Post -Body $payload -ContentType "application/json"
