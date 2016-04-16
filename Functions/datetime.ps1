
$pattern = '^(?<DayOfWeek>(Sun|Mon|Tue|Wed|Thu|Fri|Sat)) (?<Month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)) (?<Day>[0-9]{2}) (?<Hour>[0-9]{2}):(?<Minute>[0-9]{2}):(?<Second>[0-9]{2}) (?<Year>[0-9]{4})'
function Test-OmDateTime
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $DateString
    )
    process
    {
        $DateString -match $pattern
    }
}
function ConvertFrom-OmDateTime
{
    [CmdletBinding()]
    [OutputType([DateTime])]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $DateString
    )
    process
    {
        $groups = ([regex]$pattern).Match($DateString).Groups
        $splat = @{
            Month = @{
                Jan = 1; Feb = 2; Mar = 3; Apr = 4; May = 5; Jun = 6;
                Jul = 7; Aug = 8; Sep = 9; Oct = 10; Nov = 11;  Dec = 12
            }.$([string]$groups['Month'])
            Day = [int]::Parse($groups['Day'])
            Hour = [int]::Parse($groups['Hour'])
            Minute = [int]::Parse($groups['Minute'])
            Second = [int]::Parse($groups['Second'])
            Year = [int]::Parse($groups['Year'])
        }
        Get-Date @splat
    }
}
