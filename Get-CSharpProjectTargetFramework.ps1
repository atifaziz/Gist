<#
 # MIT License
 #
 # Copyright (c) 2020 Atif Aziz
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
param([switch]$UseGitGrep)

if ($GitGrep)
{
    git rev-parse --git-dir
    if ($LASTEXITCODE) {
        throw """$(Get-Location)"" is not a Git repository."
    }

    git grep -E '<TargetFrameworks?>' *.csproj |
        ? { $_ -match '^(.+?):\s*<TargetFrameworks?>\s*(.+?)\s*<' } |
        % {
            $projectPath = $matches[1]
            $matches[2] -split ';' |
                % {
                    New-Object pscustomobject -Property @{
                        Path = $projectPath;
                        Project = (Split-Path -Leaf $projectPath);
                        TargetFramework = $_.Trim();
                    }
                }
        }
}
else
{
    Get-ChildItem -Recurse -File -Filter *.csproj |
        % {
            Write-Verbose $_
            $dom = [xml](dotnet msbuild $_ /pp)
            $targetFrameworks = [string]$dom.Project.PropertyGroup.TargetFramework
            if (!$targetFrameworks) {
                $targetFrameworks = [string]$dom.Project.PropertyGroup.TargetFrameworks
                if (!$targetFrameworks) {
                    return
                }
            }
            $targetFrameworks = $targetFrameworks.Trim()
            Write-Verbose "TargetFrameworks = $targetFrameworks"
            $projectPath = $_
            $targetFrameworks |
                % {
                    New-Object pscustomobject -Property @{
                        Path = $projectPath;
                        Project = (Split-Path -Leaf $projectPath);
                        TargetFramework = $_.Trim();
                    }
                }
        }
}
