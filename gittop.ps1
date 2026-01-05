[CmdletBinding()]
param([int]$Top = 10, [switch]$LongHash = $false)

git rev-list --objects --all |
    git cat-file '--batch-check=%(objecttype) %(objectname) %(objectsize) %(rest)' |
    % { $tokens = ($_ -split ' ', 4);
        New-Object psobject -Property @{ Kind = $tokens[0];
                                         Hash = $(if ($longHash) { $tokens[1] } else { $tokens[1].Substring(0, 7) });
                                         Size = [int]$tokens[2];
                                         Name = $tokens[3] } } |
    sort -Descending Size |
    select -First $Top Kind, Size, Hash, Name
