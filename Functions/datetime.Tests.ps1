Import-Module PsOmsa -Force

Describe 'Test-OmDateTime' {
    It 'correctly matches sample dates' {
        $dates = "$($PSCommandPath | Split-Path -Parent)\..\Resources\dateTimeSamples.txt" |
            Resolve-Path |
            Get-Content

        foreach ( $date in $dates )
        {
            if ( -not (Test-OmDateTime $date) )
            {
                throw $date
            }
        }
    }
}
Describe 'ConvertFrom-OmDateTime' {
    It 'correctly converts' {
        $s = 'Sat Mar 05 02:03:31 2016'

        $r = ConvertFrom-OmDateTime $s

        $r.Month | Should be 3
        $r.Day | Should be 5
        $r.Hour | Should be 2
        $r.Minute | Should be 3
        $r.Second | Should be 31
        $r.Year | Should be 2016
    }
    It 'converts sample dates without throwing' {
        $dates = "$($PSCommandPath | Split-Path -Parent)\..\Resources\dateTimeSamples.txt" |
            Resolve-Path |
            Get-Content

        foreach ( $date in $dates )
        {
            ConvertFrom-OmDateTime $date
        }
    }
}
