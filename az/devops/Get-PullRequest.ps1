<#
 # MIT License
 #
 # Copyright (c) 2021 Atif Aziz
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

<#
.SYNOPSIS
    Lists (by default) or checks out pull requests on an Azure DevOps
    repository.
.PARAMETER Checkout
    Specifies the pull request number or branch to checkout. The branch name
    can be partial using wildcards (* or ?). If a number, it can be optionally
    prefixed with a hash/pound (#) or exclamation mark (!) that is ignored.
.PARAMETER SkipFetch
    When specified, does not perform a "git fetch" prior to checkout, assuming
    it has been performed previously and references and objects are locally
    available.
.PARAMETER SkipMerge
    When specified, does not refresh the local branch with the remote.
.PARAMETER IncludeDraft
    When specified, includes pull requests that are marked as draft.
.PARAMETER PassThru
    Outputs the retrieved pull request objects instead of the default of
    formatted output.
#>

[CmdletBinding(SupportsShouldProcess)]
param ([Parameter(ParameterSetName='Checkout', Mandatory=$true)]
       [string]$Checkout,
       [Parameter(ParameterSetName='Checkout')]
       [switch]$SkipFetch,
       [Parameter(ParameterSetName='Checkout')]
       [switch]$SkipMerge,
       [Parameter(ParameterSetName='List')]
       [Parameter(ParameterSetName='Checkout')]
       [switch]$IncludeDraft,
       [Parameter(ParameterSetName='List')]
       [switch]$PassThru)

$prettyQuery = '
    [*].{ id    : codeReviewId,
          title : title,
          ref   : sourceRefName,
          author: createdBy.displayName,
          commit: lastMergeSourceCommit.commitId,
          draft : isDraft }'

$query = $prettyQuery.Trim() -replace '\r?\n', ' '

$prs =
    az repos pr list --query $query `
        | ConvertFrom-Json `
        | Where-Object { $includeDraft -or !$_.draft }
        | Select-Object @{ N='Id'    ; E={ $_.id                              } },
                        @{ N='Commit'; E={ $_.commit.Substring(0, 8)          } },
                        @{ N='Draft' ; E={ [bool]$_.draft                     } },
                        @{ N='Author'; E={ $_.author                          } },
                        @{ N='Ref'   ; E={ $_.ref -replace '^refs/heads/', '' } },
                        @{ N='Title' ; E={ $_.title                           } }

if ($LASTEXITCODE)
{
    throw "Failed to query Azure DevOps repository pull requests (az exit code = $LASTEXITCODE)."
}

if ($PSCmdlet.ParameterSetName -eq 'List')
{
    if (!$includeDraft)
    {
        $prs = $prs | Select-Object Id, Commit, Author, Ref, Title
    }

    if ($passThru)
    {
        $prs
    }
    else
    {
        $prs | Format-Table -AutoSize
    }
}
else
{
    $criteria =
        if ($checkout -match '^[!#]?([1-9][0-9]*)$')
        {
            { $_.Id -eq $matches[1] }
        }
        else
        {
            { $_.Ref -like $checkout }
        }

    $pr = @($prs | Where-Object $criteria)

    if ($pr.Length -eq 0)
    {
        throw "No pull request found matching ""$checkout""."
    }
    elseif ($pr.Length -gt 1)
    {
        throw "Expected ""$checkout"" to match a single pull request when it matched $($pr.Length)."
    }
    else
    {
        $pr = $pr[0]
        $header = "[$($pr.Commit)] $($pr.Ref) ""$($pr.Title)"""

        if ($PSCmdlet.ShouldProcess($header, 'Checkout'))
        {
            if (!$skipFetch)
            {
                git fetch

                if ($LASTEXITCODE)
                {
                    throw "Failed to fetch from remote (Git exit code = $LASTEXITCODE)."
                }
            }

            Write-Verbose "Checking out: $header"

            git checkout $pr.Ref

            if ($LASTEXITCODE)
            {
                throw "Failed to checkout pull request (Git exit code = $LASTEXITCODE)."
            }

            if (!$skipMerge)
            {
                git merge --ff-only

                if ($LASTEXITCODE)
                {
                    throw "Failed to fast-forward merge with pull request (Git exit code = $LASTEXITCODE)."
                }
            }
        }
    }
}
