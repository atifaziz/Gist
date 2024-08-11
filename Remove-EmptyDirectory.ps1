# MIT License
#
# Copyright (c) 2024 Atif Aziz
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

<#
    .SYNOPSIS
    Recursively removes empty directories only until none are left.

    .PARAMETER Path
    The path to the directory to start the search for empty directories.

    .PARAMETER IncludeDotPrefixed
    If specified, directories with names starting with a dot (.) are
    included in the search for empty directories.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline=$true)]
    [string]$Path,
    [switch]$IncludeDotPrefixed
)

if (-not (Test-Path -PathType Container $Path))
{
    Write-Error "Path '$Path' does not exist or is not a directory."
}
else
{
    $ErrorActionPreference = 'Stop'

    do
    {
        $count =
            Get-ChildItem -Recurse -Directory -Attributes '!Hidden+!System' |
            ? { $includeDotPrefixed -or $_.Name -notlike '.*' } |
            ? { (Get-ChildItem $_ | Measure-Object | Select-Object -ExpandProperty Count) -eq 0 } |
            % {
                Remove-Item -Verbose:$VerbosePreference $_
                $_
            } |
            Measure-Object |
            Select-Object -ExpandProperty Count

        Write-Verbose "Removed $count empty directories."
    }
    while ($count)
}
