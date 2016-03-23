function Set-FileTime
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true,
                   Position = 0,
                   HelpMessage = "Specifies the path to the item to timestamp")]
        [string[]]$Path,
        [Parameter(ParameterSetName='explicit')] [DateTime]$CreationTime,
        [Parameter(ParameterSetName='explicit')] [DateTime]$LastAccessTime,
        [Parameter(ParameterSetName='explicit')] [DateTime]$LastWriteTime,
        [Parameter(ParameterSetName='template', Mandatory = $true)] [string]$TemplatePath,
        [Parameter(ParameterSetName='template')] [switch]$SetCreationTime,
        [Parameter(ParameterSetName='template')] [switch]$SetLastAccessTime,
        [Parameter(ParameterSetName='template')] [switch]$SetLastWriteTime
    )

    PROCESS 
    {
        ForEach ($path In $path) 
        {
            $file = Get-Item $path -ea Stop | ? { (-not $_.PSIsContainer) }

            $templateFile = $null
            if ($pscmdlet.ParameterSetName -eq 'template')
            {
                $templateFile = Get-Item $templatePath -ea Stop | ? { (-not $_.PSIsContainer) }
            }

            if ($file -eq $null)
            {
                Write-Verbose "Skipping directory: $path"
                continue
            }

            if (!$pscmdlet.ShouldProcess("$file"))
            {
                continue
            }

            if ($pscmdlet.ParameterSetName -eq 'explicit')
            {
                if ($creationTime   -ne $null) { $file.CreationTime   = $creationTime   }
                if ($lastAccessTime -ne $null) { $file.LastAccessTime = $lastAccessTime }
                if ($lastWriteTime  -ne $null) { $file.LastWriteTime  = $lastWriteTime  }
            }
            elseif ($templateFile -ne $null)
            {
                if ($setCreationTime  ) { $file.CreationTime   = $templateFile.CreationTime   }
                if ($setLastAccessTime) { $file.LastAccessTime = $templateFile.LastAccessTime }
                if ($setLastWriteTime ) { $file.LastWriteTime  = $templateFile.LastWriteTime  }
            }
        }
    }
}
