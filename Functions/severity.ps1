function ConvertTo-OmSeverity
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [int]
        $TypeInt
    )
    process
    {
        @{
            1 = 'Critical'
            2 = 'Non-Critical'
            3 = 'three'
            4 = 'Ok'
        }.$TypeInt
    }
}
