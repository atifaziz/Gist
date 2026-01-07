<#
.SYNOPSIS
    Generates a pull request description using GitHub Copilot CLI.

.DESCRIPTION
    This script automates the creation of pull request descriptions by analyzing
    Git diffs and commit history between a base branch and the current HEAD.

    The workflow:
    1. Determines the base branch (auto-detects main/master if not specified)
    2. Generates three intermediate files: numstat, commit log, and full diff
    3. Constructs a prompt instructing Copilot to write a PR description
    4. Invokes the Copilot CLI to generate the description

    The script supports a two-phase workflow using -Prepare, allowing you to
    review and edit the prompt before generating the final description.

.PARAMETER Base
    The base branch to compare against. If not specified, the script will
    auto-detect common base branches (main, master).

.PARAMETER Head
    The head commit or branch to compare. Defaults to HEAD.

.PARAMETER KeepFiles
    When specified, retains the intermediate files (numstat, commits, diff)
    after the script completes. Useful for debugging or manual review.

.PARAMETER CopilotBinPath
    Path to the Copilot CLI executable. Defaults to 'copilot' (assumes it's in PATH).

.PARAMETER Model
    The AI model to use with Copilot CLI. If not specified, uses Copilot's default.

.PARAMETER Prepare
    Generates the prompt file without invoking Copilot, allowing you to review
    and edit the prompt before running the script again to generate the description.

.PARAMETER PreparedPromptFile
    The filename for the prepared prompt. Defaults to '.pr.txt'.

.PARAMETER Suffix
    An optional suffix to append to generated filenames. Useful when working
    with multiple PRs simultaneously, or when generating multiple description
    samples in sequence or parallel to compare outputs.

.EXAMPLE
    .\Describe-PullRequest.ps1

    Generates a PR description comparing the auto-detected base branch (main or master)
    against HEAD using default settings.

.EXAMPLE
    .\Describe-PullRequest.ps1 -Base develop

    Generates a PR description comparing the 'develop' branch against HEAD.

.EXAMPLE
    .\Describe-PullRequest.ps1 -Prepare

    Creates a prompt file (.pr.txt) without generating the description. You can
    edit this file, then run the script again to use your customized prompt.

.EXAMPLE
    .\Describe-PullRequest.ps1 -KeepFiles

    Generates a PR description and retains the intermediate numstat, commit log,
    and diff files for review.

.EXAMPLE
    .\Describe-PullRequest.ps1 -Model gpt-4

    Generates a PR description using a specific AI model.

.EXAMPLE
    .\Describe-PullRequest.ps1 -Base main -Head feature/my-feature -Suffix "-feature"

    Generates a PR description for a specific feature branch with a custom suffix
    for the intermediate files.

.EXAMPLE
    1..3 | % {
      Start-Job {
        $n = $args[0]
        .\Describe-PullRequest.ps1 -Verbose -Suffix "-$n" > "pr-$n.md"
      } -Name "PR#$_" -ArgumentList $_
    }

    Generates multiple PR description samples in parallel using background jobs.
    Each sample uses a unique suffix to avoid file conflicts, and outputs are
    saved to separate markdown files (pr-1.md, pr-2.md, pr-3.md) for comparison.

.NOTES
    Prerequisites:
    - Git must be installed and available in PATH
    - GitHub Copilot CLI must be installed (minimum version 0.0.368)
    - Must be run from within a Git repository

    Install Copilot CLI: https://docs.github.com/en/copilot/github-copilot-in-the-cli

.LINK
    https://docs.github.com/en/copilot/github-copilot-in-the-cli
#>

<#
 # MIT License
 #
 # Copyright (c) 2025 Microsoft Corporation
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

[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Generate')]
param (
    [string]$Base,
    [string]$Head = 'HEAD',
    [Parameter(ParameterSetName = 'Generate')]
    [switch]$KeepFiles = $false,
    [Parameter(ParameterSetName = 'Generate')]
    [string]$CopilotBinPath = 'copilot',
    [Parameter(ParameterSetName = 'Generate')]
    [string]$Model,
    [Parameter(ParameterSetName = 'Prepare')]
    [switch]$Prepare = $false,
    [string]$PreparedPromptFile = '.pr.txt',
    [string]$Suffix
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

$preparedPromptFile = "$(Split-Path -LeafBase $preparedPromptFile)$($suffix)$(Split-Path -Extension $preparedPromptFile)"

# Determine base branch if not specified using common names like "main" or "master"
if (!$base) {
    $refs = git show-ref | % { ($_ -split ' ', 2)[-1] }
    $knownBases = @('main', 'master', 'develop', 'dev')
    $base = @('master', 'main2') | ? { "refs/heads/$_" -in $refs } | Select-Object -First 1
    if (!$base) {
        throw "Unable to determine base branch. Tried: $($knownBases -join ', ')"
    }
    Write-Verbose "Determined base branch: $base"
}

if ($prepare) {
    $keepFiles = $true
}
else {
    if (Test-Path -PathType Leaf -Path $preparedPromptFile) {
        Write-Verbose 'A prepared pull request prompt was found and will be used.'
        $prompt = Get-Content -Raw -Path $preparedPromptFile
    }

    $version = [version](& $copilotBinPath --version | Select-Object -First 1)
    $requiredMinVersion = [version]'0.0.368'
    if ($version.Major -ne 0 -or $version -lt $requiredMinVersion) {
        throw "Copilot version $requiredMinVersion or higher is required within the major version band. Installed version: $version"
    }
}

$sha = git rev-parse --short=8 HEAD

$numstatFileName = "numstat-$sha$suffix.txt"
$commitLogFileName = "commits-$sha$suffix.txt"
$diffFileName = "diff-$sha$suffix.txt"

$logRange = "$base..$head"    # 2 dots for log to exclude base commit!
$diffRange = "$base...$head"  # 3 dots for diff to include base commit changes!
Write-Verbose "Delta range: $diffRange"

try {
    if ($null -eq $prompt) {
        Write-Verbose "Generating diff stats: $numstatFileName"
        git diff --numstat $diffRange > $numstatFileName
        Write-Verbose "Generating commit log: $commitLogFileName"
        git log --oneline $logRange > $commitLogFileName
        Write-Verbose "Generating diff: $diffFileName"
        git diff $diffRange > $diffFileName

        $prompt = "
Goal: Write a PR description

The title for the PR should be a simple and concise description of the changes
made. It should be written in the imperative mood, starting with a verb. For
example, `"Fix bug in user authentication`" or `"Add new feature for data
visualization`". The title should not include any personal opinions or
unnecessary details.

The description should:

- start with an overview, then go into technical details.
- provide a more detailed explanation of the changes, including the motivation
  behind them and any relevant context.
- not be just a summary of the physical code changes, but rather a logical
  explanation of the changes, including why where possible.
- information about any related issues or pull requests, as well as any testing
  that was done to verify the changes.

## Files Changed

Read the ``$numstatFileName`` file for a summary of the files changed, lines added, and lines removed.

## Commits

Read the ``$commitLogFileName`` file for a summary of the commits made.

## Changes

Read the ``$diffFileName`` file for the full diff of the changes made.

## Description
"
    }

    $prompt = "$($prompt.Trim())`n"

    if ($prepare) {
        Set-Content $preparedPromptFile $prompt
    }

    elseif ($VerbosePreference -ne 'SilentlyContinue') {
        $prompt -split '\r?\n' | ForEach-Object { Write-Host "> $_" -ForegroundColor DarkGray }
    }

    if (!$prepare -and $PSCmdlet.ShouldProcess("Generate PR description", "Using Copilot")) {
        $copilotArgs = @()

        if ($model) {
            $copilotArgs += @('--model', $model)
        }

        & $copilotBinPath --deny-tool write -s @copilotArgs -p $prompt
    }
}
finally {
    if (!$keepFiles) {
        Remove-Item -ErrorAction SilentlyContinue `
            $numstatFileName, $commitLogFileName, $diffFileName, `
            $preparedPromptFile
    }
}
