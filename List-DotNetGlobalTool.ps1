dotnet tool list -g |
    Select-Object -Skip 2 |
    % {
        $tokens = $_ -split ' +', 3;
        [pscustomobject]@{
            PackageId = $tokens[0]
            Version   = [version]$tokens[1]
            Command   = $tokens[2]
        }
    } |
    ? { $_.PackageId -match '^[a-z]([a-z0-9.-]*[a-z0-9])?$' }
