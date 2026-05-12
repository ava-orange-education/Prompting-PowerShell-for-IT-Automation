# Scenario: A real-time dashboard for 'Abandoned' project detection
$data = Search-AzGraph -Query "Resources | where tags['Environment'] == 'Dev' | project name, type, location"
# Ask AI to identify 'High Risk' items based on the data
$analysisPrompt = "Review this list of Dev resources. Which ones have been running longest without updates? Provide a 2-sentence risk summary."
$riskSummary = Get-AIAnalysis -InputData $data -Prompt $analysisPrompt
# Generate the dashboard content
$htmlHeader = "<h1>Real-Time Project Health</h1><p><b>AI Insight:</b> $riskSummary</p>"
$htmlTable = $data | ConvertTo-Html -Fragment
$finalReport = $htmlHeader + $htmlTable
$finalReport | Out-File "ProjectHealth.html"

# Get-AIAnalysis is not a standard function but a placeholder. You can build the function with your go to AI. You can swap the backend (OpenAI, Claude, or local LLMs) without rewriting your entire monitoring script.