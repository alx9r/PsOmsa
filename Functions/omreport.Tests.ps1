Import-Module PsOmsa -Force

InModuleScope PsOmsa {
Describe ConvertFrom-OmreportStream {
    It 'too few delimited lines.' {
        { ConvertFrom-OmreportStream 's' } |
            Should Throw 'OmreportStream contained fewer than 2 delimited lines.'
    }
    It 'no headings.' {
        { ConvertFrom-OmreportStream ';',';' } |
            Should Throw 'OmreportStream contains blank headings.'
    }
    Context 'column count mismatch' {
        Mock Write-Warning -Verifiable
        ConvertFrom-OmreportStream 'a;b','1;2;3'

        Assert-MockCalled Write-Warning -Times 1 {
            $Message -eq 'Number of columns in line differ from number of columns in header. Omitting line: 1;2;3'
        }
    }
    It 'correct UndelimitedLines' {
        $s = @(
            'undelimited line'
            'undelimited line 2'
            'a;b'
            '1;2'
        )
        $r = ConvertFrom-OmreportStream $s

        $r.UndelimitedLines.Count | Should be 2
        $r.UndelimitedLines[0] | Should be 'undelimited line'
        $r.UndelimitedLines[1] | Should be 'undelimited line 2'
    }
    It 'correct DelimitedLines' {
        $s = @(
            'a;b'
            '1;2'
        )
        $r = ConvertFrom-OmreportStream $s

        $r.DelimitedLines.Count | Should be 2
        $r.DelimitedLines[0] | Should be 'a;b'
        $r.DelimitedLines[1] | Should be '1;2'
    }
    It 'correct headings' {
        $s = @(
            'a;b'
            '1;2'
        )
        $r = ConvertFrom-OmreportStream $s

        $r.Headings.Count | Should be 2
        $r.Headings[0] | Should be 'a'
        $r.Headings[1] | Should be 'b'
    }
    It 'correct objects' {
        $s = @(
            'a;b'
            '1;2'
            '3;4'
        )
        $r = ConvertFrom-OmreportStream $s

        $r.Objects.Count | Should be 2
        $r.Objects[0].a | Should be 1
        $r.Objects[0].b | Should be 2
        $r.Objects[1].a | Should be 3
        $r.Objects[1].b | Should be 4
    }
    It 'accepts pipeline input' {
        $r = @(
            'a;b'
            '1;2'
            '3;4'
        ) | ConvertFrom-OmreportStream

        $r.Objects.Count | Should be 2
        $r.Objects[0].a | Should be 1
        $r.Objects[0].b | Should be 2
        $r.Objects[1].a | Should be 3
        $r.Objects[1].b | Should be 4
    }
}
}
