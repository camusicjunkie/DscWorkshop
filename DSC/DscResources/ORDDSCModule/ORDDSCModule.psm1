
enum Ensure
{
	Present
	Absent
}

[DscResource()]
class ORDIPAdapter # What resource should be here?
{
    [DscProperty(Key)]
    [string]$InterfaceAlias
    [DscProperty(Mandatory)]
    [string] $ORDIPAddress
    [DscProperty(Mandatory)]
    [Ensure]$Ensure
    [DscProperty()]
    [string] $AddressFamily = 'IPv4'
    [DscProperty()]
    [string] $PrefixLength = '24'
    [void] Set()
    {
	    Get-NetAdapter | Where-Object {$_.name -eq "$($this.InterfaceAlias)"} | New-NetIPAddress -IPAddress $this.ORDIPAddress -PrefixLength $this.PrefixLength
    }
    [bool] Test()
    {
	    $result = Get-NetAdapter | Where-Object {$_.name -eq "$($this.InterfaceAlias)"} | Get-NetIPAddress | where-object {$_.addressfamily -eq $this.AddressFamily}
	    return $result
    }
    [ORDIPAdapter] Get()
    {
        $AF = Get-NetAdapter | Where-Object {$_.name -eq "$($this.InterfaceAlias)"} | Get-NetIPAddress | where-object {$_.addressfamily -eq $this.AddressFamily}
        if ($null -eq $AF) {
		    $this.Ensure = [Ensure]::Absent
        }
	    else {
        	Write-Verbose "AF $AF"
		    $this.Ensure = [Ensure]::Present
    	}
	    return $this
    }
} # This module defines a class for a DSC "ORDIPAdapter" provider.
