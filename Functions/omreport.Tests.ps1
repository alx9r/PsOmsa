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
    Context 'too many columns' {
        Mock Write-Warning -Verifiable
        ConvertFrom-OmreportStream 'a;b','1;2;3'

        Assert-MockCalled Write-Warning -Times 1 {
            $Message -eq 'Number of columns in higher than number of columns in header. Omitting line: 1;2;3'
        }
    }
    It 'no properties for missing columns at end of line' {
        $s = @(
            'a;b;c'
            '1;2'
        )
        $r = ConvertFrom-OmreportStream $s -ParentData

        $r.Objects.Count | Should be 1
        $r.Objects[0].a | Should be 1
        $r.Objects[0].b | Should be 2
        $r.Objects[0] | Get-Member | ? {$_.Name -eq 'c'} |
            Should not BeNullOrEmpty
        $r.Objects[0].c | Should beNullOrEmpty
    }
    It 'correct UndelimitedLines' {
        $s = @(
            'undelimited line'
            'undelimited line 2'
            'a;b'
            '1;2'
        )
        $r = ConvertFrom-OmreportStream $s -ParentData

        $r.UndelimitedLines.Count | Should be 2
        $r.UndelimitedLines[0] | Should be 'undelimited line'
        $r.UndelimitedLines[1] | Should be 'undelimited line 2'
    }
    It 'correct DelimitedLines' {
        $s = @(
            'a;b'
            '1;2'
        )
        $r = ConvertFrom-OmreportStream $s -ParentData

        $r.DelimitedLines.Count | Should be 2
        $r.DelimitedLines[0] | Should be 'a;b'
        $r.DelimitedLines[1] | Should be '1;2'
    }
    It 'correct headings' {
        $s = @(
            'a;b'
            '1;2'
        )
        $r = ConvertFrom-OmreportStream $s -ParentData

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
        $r = ConvertFrom-OmreportStream $s -ParentData

        $r.Objects.Count | Should be 2
        $r.Objects[0].a | Should be 1
        $r.Objects[0].b | Should be 2
        $r.Objects[1].a | Should be 3
        $r.Objects[1].b | Should be 4
    }
    It 'returns an array.' {
        $s = @(
            'a;b'
            '1;2'
            '3;4'
        )
        $r = ConvertFrom-OmreportStream $s

        $r -is [array] | Should be $true
    }
    It 'returns an array for a single entry.' {
        $s = @(
            'a;b'
            '1;2'
        )
        $r = ConvertFrom-OmreportStream $s

        $r -is [array] | Should be $true
    }
    It 'accepts pipeline input' {
        $r = @(
            'a;b'
            '1;2'
            '3;4'
        ) | ConvertFrom-OmreportStream -ParentData

        $r.Objects.Count | Should be 2
        $r.Objects[0].a | Should be 1
        $r.Objects[0].b | Should be 2
        $r.Objects[1].a | Should be 3
        $r.Objects[1].b | Should be 4
    }
    It 'just produces objects by default' {
        $r = @(
            'a;b'
            '1;2'
            '3;4'
        ) | ConvertFrom-OmreportStream

        $r.Count | Should be 2
        $r[0].a | Should be 1
        $r[0].b | Should be 2
        $r[1].a | Should be 3
        $r[1].b | Should be 4
    }
}
Describe ConvertFrom-OmreportSystemVersion {
    It 'has incorrect title.' {
        $s = 'wrong title'

        { ConvertFrom-OmreportSystemVersion $s } |
            Should throw 'OmreportStream does not begin with "Version Report".'
    }
    It 'extracts correct title.' {
        $s = @(
            'Version Report'
            'title'
            'Name;a'
            'Version;1'
            'second title'
        )

        $r = ConvertFrom-OmreportSystemVersion $s

        $r.Title | Should be 'Version Report'
    }
    It 'produces an object not a hashtable' {
        $s = @(
            'Version Report'
            'title'
            'Name;a'
            'Version;1'
            'second title'
        )

        $r = ConvertFrom-OmreportSystemVersion $s

        $r -is [psobject] | Should be $true
        $r -is [hashtable] | Should be $false
    }
    It 'extracts correct first section.' {
        $s = @(
            'Version Report'
            'title'
            'Name;a'
            'Version;1'
            'second title'
        )
        $r = ConvertFrom-OmreportSystemVersion $s

        $r.Sections.Count | Should be 2
        $r.Sections.Keys -contains 'title' | Should be $true
        $r.Sections.title.StartIndex | Should be 1
        $r.Sections.title.EndIndex | Should be 3
        $r.Sections.title.Versions.Count | Should be 1
        $r.Sections.title.Versions.Keys -contains 'a' | Should be $true
        $r.Sections.title.Versions.a | should be '1'
    }
    It 'extracts correct last section.' {
        $s = @(
            'Version Report'
            'title'
            ';'
            ';'
            'title2'
            'Name;b'
            'Version;2'
        )
        $r = ConvertFrom-OmreportSystemVersion $s

        $r.Sections.Count | Should be 2
        $r.Sections.Keys -contains 'title2' | Should be $true
        $r.Sections.title2.StartIndex | Should be 4
        $r.Sections.title2.EndIndex | Should be 6
        $r.Sections.title2.Versions.Count | Should be 1
        $r.Sections.title2.Versions.Keys -contains 'b' | Should be $true
        $r.Sections.title2.Versions.b | Should be '2'
    }
    It 'extracts multiple versions.' {
        $s = @(
            'Version Report'
            'title'
            'Name;a'
            'Version;1'
            'Name;b'
            'Version;2'
        )
        $r = ConvertFrom-OmreportSystemVersion $s

        $r.Sections.title.Versions.a | Should be '1'
        $r.Sections.title.Versions.b | Should be '2'
    }
    Context 'missing version.' {
        Mock Write-Warning -Verifiable
        It 'warns when name is provided without version.' {
            $s = @(
                'Version Report'
                'title'
                'Name;a'
            )
            $r = ConvertFrom-OmreportSystemVersion $s

            Assert-MockCalled Write-Warning -Times 1 {
                $Message -eq 'Section title has name a but no corresponding version.'
            }
        }
    }
    Context 'missing name.' {
        Mock Write-Warning -Verifiable
        It 'warns when version is provided without name.' {
            $s = @(
                'Version Report'
                'title'
                'Version;1'
            )
            $r = ConvertFrom-OmreportSystemVersion $s

            Assert-MockCalled Write-Warning -Times 1 {
                $Message -eq 'Version Number 1 found without a name.'
            }
        }
    }
}
}
