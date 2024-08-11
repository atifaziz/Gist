<#
 # MIT License
 #
 # Copyright (c) 2022 Atif Aziz
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
param([string]$Commitish = 'HEAD',
      [int]$Count,
      [switch]$Reverse = $false,
      [string]$WorkingDirectory)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

$gitArgs = @()
if ($workingDirectory) { $gitArgs += @('-C', $workingDirectory) }

$gitLogArgs = @()
if ($reverse) { $gitLogArgs += '--reverse' }
if ($count -gt 0) { $gitLogArgs += "-$count" }

git @gitArgs log @gitLogArgs '--pretty=%h;%an;%aI;%cn;%cI;%s' $commitish |
    ForEach-Object `
    {
        $tokens = $_ -split ';', 6

        [pscustomobject]@{
            Commit = $tokens[0];
            Author = $tokens[1];
            Date = [datetimeoffset]$tokens[2];
            Committer = $tokens[3];
            CommitDate = [datetimeoffset]$tokens[4];
            Subject = $tokens[5]
        }
    }
