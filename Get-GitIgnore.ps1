# Copyright (c) 2018 Atif Aziz. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$LocalGitIgnoreClone,
    [Parameter(ValueFromPipeline=$true)]
    [string[]]$Ignore,
    [switch]$CreateFile,
    [string]$OutFile,
    [switch]$Force,
    [switch]$WithHeading)

BEGIN {

    $ErrorActionPreference = 'Stop'

    if (-not (Test-Path -Type Container $localGitIgnoreClone)) {
        git clone https://github.com/github/gitignore.git $localGitIgnoreClone
        if ($LASTEXITCODE) {
            Write-Error "Failed to clone remote."
        }
    }

    if ($createFile -and -not $outFile) {
        $outFile = '.gitignore'
    }

    if ($outFile) {
        New-Item -ItemType File -Force:$force $outFile | Out-Null
    }
}

PROCESS {

    if (-not $Ignore) {

        dir -Recurse -File (Join-Path $localGitIgnoreClone  *.gitignore) |
            select -ExpandProperty Name |
            % { $_ -replace '\.gitignore$', '' }

    } else {

        $ignore `
        | % {

            Write-Verbose "Searching for a template for $_"

            [IO.FileInfo[]]$files =
                dir -Recurse -File (Join-Path $localGitIgnoreClone "$_.gitignore")

            if (-not $files) {
                Write-Error "Missing ignore template for $_."
            }

            if ($files.Length -gt 1) {
                Write-Error "Ambiguous templates ($($files.Length)) for $_."
            }

            $file = $files[0]
            Write-Verbose "$_ -> $file"

            $heading =
                if ($withHeading) {
@"
#-----------------------------------------------------------------------
# $_
#
"@
                }

            if ($heading) {
                if ($outFile) {
                    echo $heading | Add-Content -Encoding Ascii $outFile
                } else {
                    echo $heading
                }
            }

            if ($outFile) {
                type $file | Add-Content -Encoding Ascii $outFile
            } else {
                type $file
            }
        }
    }
}
