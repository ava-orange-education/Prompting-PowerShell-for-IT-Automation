function Get‑StaleADUser {  
    [CmdletBinding(SupportsShouldProcess)]  
    param(  
        [Parameter(Mandatory,ValueFromPipeline)]  
        [int]$DaysInactive=90,  
        [ValidateScript({Test‑Path $_})]  
        [string]$BaselineCsv  
    )  
    begin { $cutoff = (Get‑Date).AddDays(‑$DaysInactive).ToFileTime() }  
    process {  
        if ($PSCmdlet.ShouldProcess($_.SamAccountName,"Query stale status")) {  
            # core logic here  
        }  
    }  
}  
