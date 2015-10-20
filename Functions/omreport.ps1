

function ConvertFrom-OmreportStream
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1)]
        [object[]]
        $OmreportStream,

        [string]
        $Delimiter = ';'
    )
    process
    {
        $h = @{}
        $h.Delimiter = $delimiter
        $h.DelimitedLines = $OmreportStream | ? { $_ -match $delimiter }

        if ($h.DelimitedLines.Count -lt 2)
        {
            throw New-Object System.ArgumentException(
                'OmreportStream contained fewer than 2 delimited lines.',
                'OmreportStream'
            )
        }

        $h.UndelimitedLines = $OmreportStream | ? { $_ -notmatch $delimiter }

        $h.HeadingsLine = $h.DelimitedLines | Select -First 1
        $h.Headings = $h.HeadingsLine.Split($delimiter)

        if ($h.Headings | ? {$_ -eq [System.String]::Empty})
        {
            throw New-Object System.ArgumentException(
                'OmreportStream contains blank headings.',
                'OmreportStream'
            )
        }

        $objects = [System.Collections.ArrayList]@()

        foreach
        (
            $line in $h.DelimitedLines |
                ? {$_ -ne $h.HeadingsLine}
        )
        {
            $properties = $line.Split($delimiter)

            if ( $h.Headings.Count -ne $properties.Count )
            {
                Write-Warning "Number of columns in line differ from number of columns in header. Omitting line: $line"
                continue
            }

            $i = 0
            $thisHash = @{}
            foreach ($heading in $h.Headings)
            {
                $thisHash.$heading = $properties[$i]
                $i++
            }

            $objects.Add(
                [pscustomobject]$thisHash
            ) | Out-Null
        }

        $h.Objects = $objects

        return [pscustomobject]$h
    }
}
