function Touch-Item
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true,
                   HelpMessage = "Specifies the path to the item to touch")]
        [string[]]$Path,
        [switch]$Force = $false
    )

    PROCESS 
    {
        ForEach ($path In $path) 
        {
            $file = Get-Item $path -ea Stop `
                  | ? { !$_.PSIsContainer `
                        -and 0 -eq ($file.Attributes -band ([IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System)) }

            if ($file -eq $null)
            {
                Write-Verbose "Skipping directory: $path"
                continue
            }
            if (!$pscmdlet.ShouldProcess("$file"))
            {
                continue
            }
            
            $attributes = $file.Attributes
            $ro = [IO.FileAttributes]::ReadOnly -eq ($attributes -band [IO.FileAttributes]::ReadOnly)
            if ($ro)
            {
                if (!$force)
                {
                    Write-Warning "Skipping file ""$file"" as it is read-only. Use -Force to still touch the file."
                    continue
                }

                $file.Attributes = $attributes -band (-bnot [IO.FileAttributes]::ReadOnly)
            }
            
            $file.LastWriteTime = Get-Date
            if ($ro)
            {
                $file.Attributes = $file.Attributes -bor [IO.FileAttributes]::ReadOnly
            }

            Write-Output $file
        }
    }
}
 
<#    
dir * | Touch-Item -WhatIf
#>
