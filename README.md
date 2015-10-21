[![Build status](https://ci.appveyor.com/api/projects/status/r8mqw7hg1rri1imn/branch/master?svg=true&passingText=master%20-%20OK)](https://ci.appveyor.com/project/alx9r/toolfoundations/branch/master)

# PowerShell Module for Dell OMSA
PowerShell bindings for the Dell Open Management Server Administration command line interface.

# Why does this exist?

This module exists because the only Dell-supported scriptable API to the PERC family of controllers seems to be the OMSA CLI commands `omreport` and `omconfig`.  The input and output to those commands is character strings.  Appropriately converting to and from those character strings is an arcane task.  This module exists to provide a single location where the arcane conversions are implemented.

# What is implemented?

Parsing of the output of `omreport` is implemented.  Piping the output of `omreport` to `ConvertFrom-OmreportStream` produces a stream of sensible powershell objects.

# How do I use this module? 

First take a look at the stream of character output by `omreport` in your environment.  In my environment, the following command is interesting because it shows information about the 14 physical disks attached to a PERC 710P:

````Shell
omreport storage pdisk controller=0 
````

First, get the output of `omreport` formatted in semicolon-separated-value using the `-fmt ssv` switch:

````PowerShell
$s = omreport storage pdisk controller=0 -fmt ssv
````

This will put a rather unreadable stream of characters output by `omreport` in `$s`.

You can wrap the call to `omreport` in `Invoke-Command` to retrieve the stream from a remote computer:

````PowerShell
$s = Invoke-Command s01.ad.example.com { omreport storage pdisk controller=0 -fmt ssv}
````

Now convert the character stream in `$s` to PowerShell objects:

````PowerShell
$disks = $s | ConvertFrom-OmreportStream
````
`$disks` now contains a list of 14 PowerShell objects, one for each hard drive in my environment.  I can get count the hard drives like this:

````PowerShell
$disks.Count
````

Now that we have nice objects corresponding to the disks, we can do useful things using idiomatic PowerShell.  Here is a listing of physical IDs, and capacities: 

````PowerShell
$disks | Select ID,Capacity
````

The result looks like this:

````
ID      Capacity                                                          
--      --------                                                          
0:1:0   558.38 GB (599550590976 bytes)                                    
0:1:1   558.38 GB (599550590976 bytes)                                    
0:1:2   558.38 GB (599550590976 bytes)                                    
0:1:3   558.38 GB (599550590976 bytes)                                    
0:1:4   558.38 GB (599550590976 bytes)                                    
0:1:5   2,794.00 GB (3000034656256 bytes)                                 
0:1:6   2,794.00 GB (3000034656256 bytes)                                 
0:1:7   2,794.00 GB (3000034656256 bytes)                                 
0:1:8   2,794.00 GB (3000034656256 bytes)                                 
0:1:9   2,794.00 GB (3000034656256 bytes)                                 
0:1:10  2,794.00 GB (3000034656256 bytes)                                 
0:1:11  2,794.00 GB (3000034656256 bytes)                                 
0:1:12  278.88 GB (299439751168 bytes)                                    
0:1:13  278.88 GB (299439751168 bytes)
````

We can retrieve the ID and model of the dedicated hot spares:

````PowerShell
$disks | 
	Where { $_.'Hot Spare' -eq 'Dedicated' } | 
	Select ID,'Product ID'
````

Which outputs this:

````Shell
ID      Product ID                                              
--      ----------                                              
0:1:4   HUS156060VLS600                                         
0:1:11  HUS723030ALS640
````
