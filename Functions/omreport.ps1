function ConvertFrom-OmreportStream
{
<#
.SYNOPSIS
Converts the output of omreport to a rich object.

.DESCRIPTION
ConvertFrom-OmreportStream converts the output of the Dell Open Management Server Administation command line tool "omreport".  The output of omreport is a character stream.  ConvertFrom-OmreportStream outputs a rich object representing the contents of the character stream.  The objects output by ConvertFrom-OmreportStream can be manipulated using idiomatic PowerShell.

The output of omreport should be in semicolon-separated-values "ssv" format.  ssv format is selected by providing the "-fmt ssv" option to omreport.  Other delimiters might work and can be specified by Delimiter.

.OUTPUTS
The object representing the contents of the omreport character stream.

.EXAMPLE
    Out-Null
    omreport storage pdisk controller=0 -fmt ssv |
        ConvertFrom-OmreportStream |
        ? {$_.'Hot Spare' -eq 'Dedicated'} |
        select ID,Capacity

The code above outputs the physical ID and capacity of hard drives that are dedicated hot spares connected to controller 0.

#>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        # The stream object output by omreport when invoked from PowerShell.
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [object[]]
        $OmreportStream,

        # The character(s) used to delimit the fields in the omreport character stream.
        [string]
        $Delimiter = ';'
    )
    begin
    {
        $accumulator = [System.Collections.ArrayList]@()
    }
    process
    {
        $OmreportStream |
            % {
                $accumulator.Add($_) | Out-Null
            }
    }
    end
    {
        $h = @{}
        $h.Delimiter = $delimiter
        $h.DelimitedLines = $accumulator | ? { $_ -match $delimiter }

        if ($h.DelimitedLines.Count -lt 2)
        {
            throw New-Object System.ArgumentException(
                'OmreportStream contained fewer than 2 delimited lines.',
                'OmreportStream'
            )
        }

        $h.UndelimitedLines = $accumulator | ? { $_ -notmatch $delimiter }

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
