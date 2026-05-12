function Get‑OrphanHomeDirs {  
    param(  
        [Parameter(Mandatory)]  
        [string]$HomeRoot = "\\fileserver\homes",  
        [string]$CsvPath = "OrphanInventory.csv"  
    )  
    Import‑Module ActiveDirectory  
    $results = @()  
    Get‑ChildItem $HomeRoot ‑Directory | ForEach {  
        $sam = $_.Name  
        $user = Get‑ADUser ‑Filter "SamAccountName ‑eq '$sam'" ‑Properties Enabled ‑ErrorAction SilentlyContinue  
        $status = if (!$user) { "Missing" } elseif (!$user.Enabled) { "Disabled" } else { "Active" }  
        $results += [PSCustomObject]@{ FolderPath=$_.FullName; SamAccountName=$sam; Status=$status }  
    }  
    $results | Export‑Csv $CsvPath ‑NoType  
    Write‑Output "Saved to $CsvPath"  
}  
