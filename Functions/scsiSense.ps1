
$scsiSensePattern = '^Unexpected sense\.?\s*SCSI sense data:\s*Sense key:\s*(?<Key>[0-9]*)\s*Sense code:\s*(?<Code>[0-9]*)\s*Sense qualifier:\s*(?<Qualifier>[0-9]*):\s*Physical Disk\s*(?<PhysicalDiskId>[0-9]*:[0-9]*:[0-9]*)\s*Controller\s*(?<ControllerId>[0-9]*),?\s*Connector\s*(?<ConnectorId>[0-9]*)\s*$'
function Test-OmScsiSenseDescription
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $DescriptionString
    )
    process
    {
        $DescriptionString -match $scsiSensePattern
    }
}
function ConvertFrom-OmScsiSenseDescription
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
        $DescriptionString
    )
    process
    {
        $regex = [regex]$scsiSensePattern
        $match = $regex.Match($DescriptionString)

        $h = @{}
        foreach ($name in $regex.GetGroupNames())
        {
            if ($name -eq 0)
            {
                continue
            }
            $h.$name = $match.Groups[$name].Value
        }
        return $h
    }
}
