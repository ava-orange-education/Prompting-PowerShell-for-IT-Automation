function Parse‑CustomIISLog {  
    param([string[]]$LogLines)  
    $lines | ForEach {  
if ($_ -match '^(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s+([A-Z]+)\s+(/[^ ]+)\s+(\d+)\s+([\d.]+)\s+"([^"]+)"\s+"([^"]+)"') {  
            [PSCustomObject]@{  
Timestamp=[DateTime]$matches[1];
Method=$matches[2];
Path=$matches[3];
Status=[int]$matches[4];
Latency=[double]$matches[5];
UserAgent=$matches[6];
Token=$matches[7]  
}  
}  
}
}
