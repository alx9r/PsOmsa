Import-Module PsOmsa -Force

Describe 'Test-OmScsiSenseDescription' {
    It 'correctly matches sample description' {
        $descriptions = "$($PSCommandPath | Split-Path -Parent)\..\Resources\scsiSenseSamples.txt" |
            Resolve-Path |
            Get-Content

        foreach ( $description in $descriptions )
        {
            if ( -not (Test-OmScsiSenseDescription $description) )
            {
                throw $description
            }
        }
    }
}
Describe 'ConvertFrom-OmScsiSenseDescription' {
    It 'correctly converts' {
        $s = 'Unexpected sense. SCSI sense data: Sense key:  3 Sense code: 11 Sense qualifier:  1:  Physical Disk 0:1:2 Controller 4, Connector 5'

        $r = ConvertFrom-OmScsiSenseDescription $s

        $r.Key | Should be '3'
        $r.Code | Should be '11'
        $r.Qualifier | Should be '1'
        $r.PhysicalDiskId | Should be '0:1:2'
        $r.ControllerId | Should be '4'
        $r.ConnectorId | Should be '5'
    }
    It 'converts sample description without throwing' {
        $descriptions = "$($PSCommandPath | Split-Path -Parent)\..\Resources\scsiSenseSamples.txt" |
            Resolve-Path |
            Get-Content

        foreach ( $description in $descriptions )
        {
            ConvertFrom-OmScsiSenseDescription $description
        }
    }
}
