function TimeStamp-Item
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true,
                   HelpMessage = "Specifies the path to the item to timestamp")]
        [string[]]$Path,
        [switch]$Force = $false
    )

    PROCESS
    {
        ForEach ($path In $path)
        {
            $file = Get-Item $path -ea Stop | ? { (-not $_.PSIsContainer) }
            if ($file -eq $null)
            {
                Write-Verbose "Skipping directory: $path"
                continue
            }
            $ext = $file.Extension
            $baseName = [IO.Path]::GetFileNameWithoutExtension($file.Name)
            if ($baseName -match '^(.+?)_[0-9]{8}_[0-9]{6}$')
            {
                if (-not $force)
                {
                    Write-Warning "Skipping file that already appears time-stamped: $path"
                    continue
                }
                $baseName = $matches[1]
            }
            $newName = "$($baseName)_$($file.LastWriteTimeUtc.ToString('yyyyMMdd_HHmmss'))$ext"
            Rename-Item $file $newName
        }
    }
}
