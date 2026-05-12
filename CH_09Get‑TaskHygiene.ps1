function Get‑TaskHygiene {  
    param([string[]]$Servers, [string]$CsvPath="TaskReport.csv")  
    $results = Invoke‑Command $Servers {  
        Get‑ScheduledTask | Where { $_.Principal.UserId -like "DOMAIN\*" -and [string]::IsNullOrWhiteSpace($_.Description) } |  
        Select PSComputerName, TaskName, @{N="Principal";E={$_.Principal.UserId}}, Description  
    }  
    $results | Export‑Csv $CsvPath  
}  
