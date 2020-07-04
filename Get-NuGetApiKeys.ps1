Add-Type -AssemblyName System.Security
$config = [xml](Get-Content (Join-Path (Join-Path $env:AppData NuGet) NuGet.config))
$config.configuration.apikeys.add | % {
    $entropy = [Text.Encoding]::UTF8.GetBytes('NuGet')
    $value = [Security.Cryptography.ProtectedData]::Unprotect([Convert]::FromBase64String($_.value), $entropy, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
    New-Object PSObject -Property @{
        Source = $_.key
        ApiKey = [Text.Encoding]::UTF8.GetString($value)
    }
}
