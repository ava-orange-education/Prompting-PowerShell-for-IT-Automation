function Test‑PatchReadiness {  
    param([string[]]$Servers)  
    Invoke‑Command $Servers {  
        $disk = Get‑CimInstance Win32_LogicalDisk ‑Filter "DeviceID='C:'"  
        [PSCustomObject]@{ Server=$env:COMPUTERNAME; DiskFreeGB=($disk.FreeSpace/1GB);  
                           ServicesOK=(Get‑Service 'Spooler','LanmanServer' | Where Status ‑ne Running).Count ‑eq 0;  
                           Ready=($disk.FreeSpace/1GB ‑gt 20) }  
    } | Export‑Csv "Readiness.csv"  
}  
