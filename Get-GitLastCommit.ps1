<#
 # MIT License
 #
 # Copyright (c) 2019 Atif Aziz
 #
 # Permission is hereby granted, free of charge, to any person obtaining a copy
 # of this software and associated documentation files (the "Software"), to deal
 # in the Software without restriction, including without limitation the rights
 # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 # copies of the Software, and to permit persons to whom the Software is
 # furnished to do so, subject to the following conditions:
 #
 # The above copyright notice and this permission notice shall be included in
 # all copies or substantial portions of the Software.
 #
 # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 # SOFTWARE.
 #>
[CmdletBinding()]
param([Parameter(ValueFromPipeline = $true)]
      [string[]]$Path)

process
{
    foreach($e in $path)
    {
        if (Test-Path -PathType Container (Join-Path $e .git))
        {
            Push-Location $e
            $log = git log -1 '--pretty=%h %cI %s' 2>$null
            $logExitCode = $LASTEXITCODE
            $tip = git describe --tags
            if ($LASTEXITCODE) {
                $tip = git describe --all
            }
            Pop-Location

            if ($logExitCode)
            {
                Write-Warning "There was a problem with the reading log of `"$e`"."
                continue
            }

            $tokens = $log -split ' ', 3

            [pscustomobject]@{
                Time    = [datetimeoffset]$tokens[1];
                Hash    = $tokens[0];
                Tip     = $tip
                Repo    = $e;
                Subject = $tokens[2]
            }
        }
    }
}
