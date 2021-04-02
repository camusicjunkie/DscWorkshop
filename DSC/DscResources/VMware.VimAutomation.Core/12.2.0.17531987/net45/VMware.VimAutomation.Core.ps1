[VMware.VimAutomation.Sdk.Interop.V1.CoreServiceFactory]::CoreService.OnImportModule(
    "VMware.VimAutomation.ViCore.Cmdlets",
    (Split-Path $script:MyInvocation.MyCommand.Path));

function global:New-DatastoreDrive([string] $Name, $Datastore){
<#
.SYNOPSIS
This function creates a new datastore drive.
.DESCRIPTION
This function creates a new drive that is mapped to a location in a datastore.
.PARAMETER Name
Specifies a name for the new drive.
.PARAMETER Datastore
Specifies the datastore for which you want to create a new drive.
#>
	begin {
		if ($Datastore) {
			Write-Output $Datastore | New-DatastoreDrive -Name $Name
		}
	}
	process {
		if ($_) {
			$ds = $_
			New-PSDrive -Name $Name -Root \ -PSProvider VimDatastore -Datastore $ds -Scope global
		}
	}
	end {
	}
}

function global:New-VIInventoryDrive([string] $Name, $Location){
<#
.SYNOPSIS
This function creates a new drive for an inventory item.
.DESCRIPTION
This function creates a new inventory drive that is mapped to a location in a datastore.
.PARAMETER Name
Specifies the name of the new inventory drive.
.PARAMETER Location
Specifies the vSphere container objects (such as folders, data centers, and clusters) for which you want to create the drive.
#>
	begin {
		if ($Location) {
			Write-Output $Location | New-VIInventoryDrive -Name $Name
		}
	}
	process {
		if ($_) {
			$location = $_
			New-PSDrive -Name $name -Root \ -PSProvider VimInventory -Location $location -Scope global
		}
	}
	end {
	}
}

function global:Get-VICommand([string] $Name = "*") {
<#
.SYNOPSIS
This function retrieves all commands of the VMware modules.
.DESCRIPTION
This function retrieves all commands of the imported VMware modules, including cmdlets, aliases, and functions.
.PARAMETER Name
Specifies the name of the command you want to retrieve.
#>
  Get-Command -Module VMware.* -Name $Name
}


function HookGetViewAutoCompleter() {	
	if ( -not (Test-Path Function:\TabExpansionDefault) ) {
		
		# This is the new definition of the TabExpansion2 function
		$tabExpansionProxyFunction = 
		'
			[CmdletBinding(DefaultParameterSetName = ''ScriptInputSet'')]
			Param(
				[Parameter(ParameterSetName = ''ScriptInputSet'', Mandatory = $true, Position = 0)]
				[string] $inputScript,

				[Parameter(ParameterSetName = ''ScriptInputSet'', Mandatory = $true, Position = 1)]
				[int] $cursorColumn,

				[Parameter(ParameterSetName = ''AstInputSet'', Mandatory = $true, Position = 0)]
				[System.Management.Automation.Language.Ast] $ast,

				[Parameter(ParameterSetName = ''AstInputSet'', Mandatory = $true, Position = 1)]
				[System.Management.Automation.Language.Token[]] $tokens,

				[Parameter(ParameterSetName = ''AstInputSet'', Mandatory = $true, Position = 2)]
				[System.Management.Automation.Language.IScriptPosition] $positionOfCursor,

				[Parameter(ParameterSetName = ''ScriptInputSet'', Position = 2)]
				[Parameter(ParameterSetName = ''AstInputSet'', Position = 3)]
				[Hashtable] $options = $null
			)

			End
			{
				if ($psCmdlet.ParameterSetName -eq ''ScriptInputSet'') {
					$shouldProcessInput = [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::ShouldProcess(
						<#inputScript#>  $inputScript,
						<#cursorColumn#> $cursorColumn,
						<#options#>        $options)
					
					if ($shouldProcessInput) {
						return [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::CompleteInput(
							<#inputScript#>  $inputScript,
							<#cursorColumn#> $cursorColumn,
							<#options#>        $options)
					} else {
						return global:TabExpansionDefault $inputScript $cursorColumn $options
					}
				} else {
					$shouldProcessInput = [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::ShouldProcess(
						<#ast#>              $ast,
						<#tokens#>           $tokens,
						<#positionOfCursor#> $positionOfCursor,
						<#options#>          $options)
					
					if ($shouldProcessInput) {
						return [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::CompleteInput(
							<#ast#>              $ast,
							<#tokens#>           $tokens,
							<#positionOfCursor#> $positionOfCursor,
							<#options#>          $options)
					} else {
						return global:TabExpansionDefault $ast $tokens $positionOfCursor $options
					}
				}
			}
		'
	
		# Declare a new function that will hold the current tab expansion implementation
		Copy-Item Function:\TabExpansion2 Function:\global:TabExpansionDefault
		
		# Override the current tab expansion implementation to hook our proxy
		Set-Item -Path Function:\TabExpansion2 -Value $tabExpansionProxyFunction
	}
}


# Aliases
set-alias Get-VIServer Connect-VIServer -Scope Global
set-alias Get-VC Connect-VIServer -Scope Global
set-alias Get-ESX Connect-VIServer -Scope Global
set-alias Answer-VMQuestion Set-VMQuestion -Scope Global
set-alias Get-PowerCLIDocumentation Get-PowerCLIHelp -Scope Global
set-alias Get-VIToolkitVersion Get-PowerCLIVersion -Scope Global
set-alias Get-VIToolkitConfiguration Get-PowerCLIConfiguration -Scope Global
set-alias Set-VIToolkitConfiguration Set-PowerCLIConfiguration -Scope Global
set-alias Export-VM Export-VApp -Scope Global
set-alias Apply-VMHostProfile Invoke-VMHostProfile -Scope Global
set-alias Apply-DrsRecommendation Invoke-DrsRecommendation -Scope Global
set-alias Shutdown-VMGuest Stop-VMGuest -Scope Global

# Uid utilities
$global:UidUtil = [VMware.VimAutomation.ViCore.Cmdlets.Utilities.UidUtil]::Create()
add-member -inputobject $global:UidUtil -membertype scriptmethod -name GetHelp -Value { Get-Help about_uid }

HookGetViewAutoCompleter

# SIG # Begin signature block
# MIIi9AYJKoZIhvcNAQcCoIIi5TCCIuECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBvIPgAyfK0gNGS
# o13JSibFq6wu7p8piZ9fn/fdI1s47qCCD8swggTMMIIDtKADAgECAhBdqtQcwalQ
# C13tonk09GI7MA0GCSqGSIb3DQEBCwUAMH8xCzAJBgNVBAYTAlVTMR0wGwYDVQQK
# ExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3Qg
# TmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMgQ2xhc3MgMyBTSEEyNTYgQ29kZSBT
# aWduaW5nIENBMB4XDTE4MDgxMzAwMDAwMFoXDTIxMDkxMTIzNTk1OVowZDELMAkG
# A1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExEjAQBgNVBAcMCVBhbG8gQWx0
# bzEVMBMGA1UECgwMVk13YXJlLCBJbmMuMRUwEwYDVQQDDAxWTXdhcmUsIEluYy4w
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCuswYfqnKot0mNu9VhCCCR
# vVcCrxoSdB6G30MlukAVxgQ8qTyJwr7IVBJXEKJYpzv63/iDYiNAY3MOW+Pb4qGI
# bNpafqxc2WLW17vtQO3QZwscIVRapLV1xFpwuxJ4LYdsxHPZaGq9rOPBOKqTP7Jy
# KQxE/1ysjzacA4NXHORf2iars70VpZRksBzkniDmurvwCkjtof+5krxXd9XSDEFZ
# 9oxeUGUOBCvSLwOOuBkWPlvCnzEqMUeSoXJavl1QSJvUOOQeoKUHRycc54S6Lern
# 2ddmdUDPwjD2cQ3PL8cgVqTsjRGDrCgOT7GwShW3EsRsOwc7o5nsiqg/x7ZmFpSJ
# AgMBAAGjggFdMIIBWTAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIHgDArBgNVHR8E
# JDAiMCCgHqAchhpodHRwOi8vc3Yuc3ltY2IuY29tL3N2LmNybDBhBgNVHSAEWjBY
# MFYGBmeBDAEEATBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Quc3ltY2IuY29tL2Nw
# czAlBggrBgEFBQcCAjAZDBdodHRwczovL2Quc3ltY2IuY29tL3JwYTATBgNVHSUE
# DDAKBggrBgEFBQcDAzBXBggrBgEFBQcBAQRLMEkwHwYIKwYBBQUHMAGGE2h0dHA6
# Ly9zdi5zeW1jZC5jb20wJgYIKwYBBQUHMAKGGmh0dHA6Ly9zdi5zeW1jYi5jb20v
# c3YuY3J0MB8GA1UdIwQYMBaAFJY7U/B5M5evfYPvLivMyreGHnJmMB0GA1UdDgQW
# BBTVp9RQKpAUKYYLZ70Ta983qBUJ1TANBgkqhkiG9w0BAQsFAAOCAQEAlnsx3io+
# W/9i0QtDDhosvG+zTubTNCPtyYpv59Nhi81M0GbGOPNO3kVavCpBA11Enf0CZuEq
# f/ctbzYlMRONwQtGZ0GexfD/RhaORSKib/ACt70siKYBHyTL1jmHfIfi2yajKkMx
# UrPM9nHjKeagXTCGthD/kYW6o7YKKcD7kQUyBhofimeSgumQlm12KSmkW0cHwSSX
# TUNWtshVz+74EcnZtGFI6bwYmhvnTp05hWJ8EU2Y1LdBwgTaRTxlSDP9JK+e63vm
# SXElMqnn1DDXABT5RW8lNt6g9P09a2J8p63JGgwMBhmnatw7yrMm5EAo+K6gVliJ
# LUMlTW3O09MbDTCCBVkwggRBoAMCAQICED141/l2SWCyYX308B7KhiowDQYJKoZI
# hvcNAQELBQAwgcoxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5j
# LjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazE6MDgGA1UECxMxKGMp
# IDIwMDYgVmVyaVNpZ24sIEluYy4gLSBGb3IgYXV0aG9yaXplZCB1c2Ugb25seTFF
# MEMGA1UEAxM8VmVyaVNpZ24gQ2xhc3MgMyBQdWJsaWMgUHJpbWFyeSBDZXJ0aWZp
# Y2F0aW9uIEF1dGhvcml0eSAtIEc1MB4XDTEzMTIxMDAwMDAwMFoXDTIzMTIwOTIz
# NTk1OVowfzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0
# aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMTAwLgYDVQQDEydT
# eW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCXgx4AFq8ssdIIxNdok1FgHnH24ke021hN
# I2JqtL9aG1H3ow0Yd2i72DarLyFQ2p7z518nTgvCl8gJcJOp2lwNTqQNkaC07BTO
# kXJULs6j20TpUhs/QTzKSuSqwOg5q1PMIdDMz3+b5sLMWGqCFe49Ns8cxZcHJI7x
# e74xLT1u3LWZQp9LYZVfHHDuF33bi+VhiXjHaBuvEXgamK7EVUdT2bMy1qEORkDF
# l5KK0VOnmVuFNVfT6pNiYSAKxzB3JBFNYoO2untogjHuZcrf+dWNsjXcjCtvanJc
# YISc8gyUXsBWUgBIzNP4pX3eL9cT5DiohNVGuBOGwhud6lo43ZvbAgMBAAGjggGD
# MIIBfzAvBggrBgEFBQcBAQQjMCEwHwYIKwYBBQUHMAGGE2h0dHA6Ly9zMi5zeW1j
# Yi5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBsBgNVHSAEZTBjMGEGC2CGSAGG+EUB
# BxcDMFIwJgYIKwYBBQUHAgEWGmh0dHA6Ly93d3cuc3ltYXV0aC5jb20vY3BzMCgG
# CCsGAQUFBwICMBwaGmh0dHA6Ly93d3cuc3ltYXV0aC5jb20vcnBhMDAGA1UdHwQp
# MCcwJaAjoCGGH2h0dHA6Ly9zMS5zeW1jYi5jb20vcGNhMy1nNS5jcmwwHQYDVR0l
# BBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIBBjApBgNVHREE
# IjAgpB4wHDEaMBgGA1UEAxMRU3ltYW50ZWNQS0ktMS01NjcwHQYDVR0OBBYEFJY7
# U/B5M5evfYPvLivMyreGHnJmMB8GA1UdIwQYMBaAFH/TZafC3ey78DAJ80M5+gKv
# MzEzMA0GCSqGSIb3DQEBCwUAA4IBAQAThRoeaak396C9pK9+HWFT/p2MXgymdR54
# FyPd/ewaA1U5+3GVx2Vap44w0kRaYdtwb9ohBcIuc7pJ8dGT/l3JzV4D4ImeP3Qe
# 1/c4i6nWz7s1LzNYqJJW0chNO4LmeYQW/CiwsUfzHaI+7ofZpn+kVqU/rYQuKd58
# vKiqoz0EAeq6k6IOUCIpF0yH5DoRX9akJYmbBWsvtMkBTCd7C6wZBSKgYBU/2sn7
# TUyP+3Jnd/0nlMe6NQ6ISf6N/SivShK9DbOXBd5EDBX6NisD3MFQAfGhEV0U5eK9
# J0tUviuEXg+mw3QFCu+Xw4kisR93873NQ9TxTKk/tYuEr2Ty0BQhMIIFmjCCA4Kg
# AwIBAgIKYRmT5AAAAAAAHDANBgkqhkiG9w0BAQUFADB/MQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQDEyBNaWNyb3NvZnQgQ29kZSBW
# ZXJpZmljYXRpb24gUm9vdDAeFw0xMTAyMjIxOTI1MTdaFw0yMTAyMjIxOTM1MTda
# MIHKMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNV
# BAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOjA4BgNVBAsTMShjKSAyMDA2IFZl
# cmlTaWduLCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkxRTBDBgNVBAMT
# PFZlcmlTaWduIENsYXNzIDMgUHVibGljIFByaW1hcnkgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkgLSBHNTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK8k
# CAgpejWeYAyq50s7Ttx8vDxFHLsr4P4pAvlXCKNkhRUn9fGtyDGJXSLoKqqmQrOP
# +LlVt7G3S7P+j34HV+zvQ9tmYhVhz2ANpNje+ODDYgg9VBPrScpZVIUm5SuPG5/r
# 9aGRwjNJ2ENjalJL0o/ocFFN0Ylpe8dw9rPcEnTbe11LVtOWvxV3obD0oiXyrxyS
# Zxjl9AYE75C55ADk3Tq1Gf8CuvQ87uCL6zeL7PTXrPL28D2v3XWRMxkdHEDLdCQZ
# IZPZFP6sKlLHj9UESeSNY0eIPGmDy/5HvSt+T8WVrg6d1NFDwGdz4xQIfuU/n3O4
# MwrPXT80h5aK7lPoJRUCAwEAAaOByzCByDARBgNVHSAECjAIMAYGBFUdIAAwDwYD
# VR0TAQH/BAUwAwEB/zALBgNVHQ8EBAMCAYYwHQYDVR0OBBYEFH/TZafC3ey78DAJ
# 80M5+gKvMzEzMB8GA1UdIwQYMBaAFGL7CiFbf0NuEdoJVFBr9dKWcfGeMFUGA1Ud
# HwROMEwwSqBIoEaGRGh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3By
# b2R1Y3RzL01pY3Jvc29mdENvZGVWZXJpZlJvb3QuY3JsMA0GCSqGSIb3DQEBBQUA
# A4ICAQCBKoIWjDRnK+UD6zR7jKKjUIr0VYbxHoyOrn3uAxnOcpUYSK1iEf0g/T9H
# BgFa4uBvjBUsTjxqUGwLNqPPeg2cQrxc+BnVYONp5uIjQWeMaIN2K4+Toyq1f75Z
# +6nJsiaPyqLzghuYPpGVJ5eGYe5bXQdrzYao4mWAqOIV4rK+IwVqugzzR5NNrKSM
# B3k5wGESOgUNiaPsn1eJhPvsynxHZhSR2LYPGV3muEqsvEfIcUOW5jIgpdx3hv08
# 44tx23ubA/y3HTJk6xZSoEOj+i6tWZJOfMfyM0JIOFE6fDjHGyQiKEAeGkYfF9sY
# 9/AnNWy4Y9nNuWRdK6Ve78YptPLH+CHMBLpX/QG2q8Zn+efTmX/09SL6cvX9/zoc
# Qjqh+YAYpe6NHNRmnkUB/qru//sXjzD38c0pxZ3stdVJAD2FuMu7kzonaknAMK5m
# yfcjKDJ2+aSDVshIzlqWqqDMDMR/tI6Xr23jVCfDn4bA1uRzCJcF29BUYl4DSMLV
# n3+nZozQnbBP1NOYX0t6yX+yKVLQEoDHD1S2HmfNxqBsEQOE00h15yr+sDtuCjqm
# a3aZBaPxd2hhMxRHBvxTf1K9khRcSiRqZ4yvjZCq0PZ5IRuTJnzDzh69iDiSrkXG
# GWpJULMF+K5ZN4pqJQOUsVmBUOi6g4C3IzX0drlnHVkYrSCNlDGCEn8wghJ7AgEB
# MIGTMH8xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlv
# bjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3lt
# YW50ZWMgQ2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBAhBdqtQcwalQC13t
# onk09GI7MA0GCWCGSAFlAwQCAQUAoIGWMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCoGCisGAQQBgjcCAQwx
# HDAaoRiAFmh0dHA6Ly93d3cudm13YXJlLmNvbS8wLwYJKoZIhvcNAQkEMSIEINVI
# vGAvgp72TCljZqA382u62ORIKr/ttqMhFQQOxgl1MA0GCSqGSIb3DQEBAQUABIIB
# AKN322uvJDiFfHxp4kk3G54V0MjZGjaA7/c5QfbkY8OTfpolNO2TibeBg07OJ9Xj
# etArOJQPTFSvdsS+m1YP0tvjtfKTQPLg6Q3YaXfpntGQoGPKQ3zBI2nMpDUCx41A
# YPV9HlYzda/BC4Eh8cS66Jw85mI5quQHEh3Vi3zWMwG6hb9C6kP7MT0y84snTvCU
# XhAFfw4nk3prj3og47B2JuhSxTbgO3nKIZ/RfWqM4GxPfpYZravCFOdlxTOkXsHu
# 2SFcJBipfXMYJV2zn4TT03C/0PKOJIqNerj1NriC2m4RbfViDYJpGyP4ulSN0/fl
# NuP3xCPlzolFHcBvEaczJKKhghAjMIIQHwYKKwYBBAGCNwMDATGCEA8wghALBgkq
# hkiG9w0BBwKggg/8MIIP+AIBAzEPMA0GCWCGSAFlAwQCAQUAMIHmBgsqhkiG9w0B
# CRABBKCB1gSB0zCB0AIBAQYJKwYBBAGgMgIDMDEwDQYJYIZIAWUDBAIBBQAEIJ6b
# EvztXjwcsEdoS8xrTP29EAmrk+qFRvBgeUyoab71Ag4BbKiJKXgAAAAAAyZm9xgT
# MjAyMTAxMjgyMzA2MjEuNzk3WjADAgEBoGOkYTBfMQswCQYDVQQGEwJKUDEcMBoG
# A1UEChMTR01PIEdsb2JhbFNpZ24gSy5LLjEyMDAGA1UEAxMpR2xvYmFsU2lnbiBU
# U0EgZm9yIEFkdmFuY2VkIC0gRzMgLSAwMDMtMDGgggxqMIIE6jCCA9KgAwIBAgIM
# M5Agd2HEJt2UUAMNMA0GCSqGSIb3DQEBCwUAMFsxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVz
# dGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE4MDYxNDEwMDAwMFoXDTI5MDMx
# ODEwMDAwMFowXzELMAkGA1UEBhMCSlAxHDAaBgNVBAoTE0dNTyBHbG9iYWxTaWdu
# IEsuSy4xMjAwBgNVBAMTKUdsb2JhbFNpZ24gVFNBIGZvciBBZHZhbmNlZCAtIEcz
# IC0gMDAzLTAxMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv3Gj+IDO
# E5Be8KfdP9KY8kE6Sdp/WC+ePDoBE8ptNJlbDCccROdW4wkv9W+rTr4nYmbGuLKH
# x2W+xsBeqT6u+yR0iyv4aARkhqo64qohj/rxnbkYMF6afAf1O3Uu2gklGav+c+lx
# neyq9j4ShYEUJPjmPpnfrvO5i9UmywSommFW7yhwqEtqKyVq5aA2ny25mofcdA4f
# QqBBOpYHDst7MtUBC1ORfVY0T7S8sHRHnKp6bF/kjlGfk5BhAz6PX0FBUHg5LRIS
# 3OvqADCyP+FtE7d1SBVrTg7Rl+NO25bZ0WKvCEHPIg/o3c7Y6pNWbtM6j2dKaki6
# /GHlbFmzEi0CgQIDAQABo4IBqDCCAaQwDgYDVR0PAQH/BAQDAgeAMEwGA1UdIARF
# MEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2Jh
# bHNpZ24uY29tL3JlcG9zaXRvcnkvMAkGA1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYI
# KwYBBQUHAwgwRgYDVR0fBD8wPTA7oDmgN4Y1aHR0cDovL2NybC5nbG9iYWxzaWdu
# LmNvbS9ncy9nc3RpbWVzdGFtcGluZ3NoYTJnMi5jcmwwgZgGCCsGAQUFBwEBBIGL
# MIGIMEgGCCsGAQUFBzAChjxodHRwOi8vc2VjdXJlLmdsb2JhbHNpZ24uY29tL2Nh
# Y2VydC9nc3RpbWVzdGFtcGluZ3NoYTJnMi5jcnQwPAYIKwYBBQUHMAGGMGh0dHA6
# Ly9vY3NwMi5nbG9iYWxzaWduLmNvbS9nc3RpbWVzdGFtcGluZ3NoYTJnMjAdBgNV
# HQ4EFgQUeaezg3HWs0B2IOZ0Crf39+bd3XQwHwYDVR0jBBgwFoAUkiGnSpVdZLCb
# tB7mADdH5p1BK0wwDQYJKoZIhvcNAQELBQADggEBAIc0fm43ZxsIEQJttimYchTL
# SH7IyY8viQ2vD/IsIZBuO7ccAaqBaMQQI0v4CeOrX+pFps4O/qSA6WtqDAD5yoYQ
# DD7/HxrpHOUil2TZrOnj6NpTYGMLt45P3NUh9J3eE2o4NeVs4yZM29Z0Z0W5TwTE
# WAgam2ZFPSQaGpJXyV8oR3hn21zKrQvotw/RthYyNCIENnJM73umvLauBMDZeKCI
# yIZrGNqWjStuIlzLf70XvZ63toZNgxBNsDKy4BOgy2DihHUU6SG9EKKktgjPOw0p
# WVmp08NMDX9CzIgUtELlugTVmEqkjQc9SR94bWVtYL38zlnrLOnFqtqt7taTrBUw
# ggQVMIIC/aADAgECAgsEAAAAAAExicZQBDANBgkqhkiG9w0BAQsFADBMMSAwHgYD
# VQQLExdHbG9iYWxTaWduIFJvb3QgQ0EgLSBSMzETMBEGA1UEChMKR2xvYmFsU2ln
# bjETMBEGA1UEAxMKR2xvYmFsU2lnbjAeFw0xMTA4MDIxMDAwMDBaFw0yOTAzMjkx
# MDAwMDBaMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNh
# MTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTI1NiAt
# IEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqpuOw6sRUSUBtpaU
# 4k/YwQj2RiPZRcWVl1urGr/SbFfJMwYfoA/GPH5TSHq/nYeer+7DjEfhQuzj46FK
# bAwXxKbBuc1b8R5EiY7+C94hWBPuTcjFZwscsrPxNHaRossHbTfFoEcmAhWkkJGp
# eZ7X61edK3wi2BTX8QceeCI2a3d5r6/5f45O4bUIMf3q7UtxYowj8QM5j0R5tnYD
# V56tLwhG3NKMvPSOdM7IaGlRdhGLD10kWxlUPSbMQI2CJxtZIH1Z9pOAjvgqOP1r
# oEBlH1d2zFuOBE8sqNuEUBNPxtyLufjdaUyI65x7MCb8eli7WbwUcpKBV7d2ydiA
# CoBuCQIDAQABo4HoMIHlMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/
# AgEAMB0GA1UdDgQWBBSSIadKlV1ksJu0HuYAN0fmnUErTDBHBgNVHSAEQDA+MDwG
# BFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20v
# cmVwb3NpdG9yeS8wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5nbG9iYWxz
# aWduLm5ldC9yb290LXIzLmNybDAfBgNVHSMEGDAWgBSP8Et/qC5FJK5NUPpjmove
# 4t0bvDANBgkqhkiG9w0BAQsFAAOCAQEABFaCSnzQzsm/NmbRvjWek2yX6AbOMRhZ
# +WxBX4AuwEIluBjH/NSxN8RooM8oagN0S2OXhXdhO9cv4/W9M6KSfREfnops7yyw
# 9GKNNnPRFjbxvF7stICYePzSdnno4SGU4B/EouGqZ9uznHPlQCLPOc7b5neVp7uy
# y/YZhp2fyNSYBbJxb051rvE9ZGo7Xk5GpipdCJLxo/MddL9iDSOMXCo4ldLA1c3P
# iNofKLW6gWlkKrWmotVzr9xG2wSukdduxZi61EfEVnSAR3hYjL7vK/3sbL/RlPe/
# UOB74JD9IBh4GCJdCC6MHKCX8x2ZfaOdkdMGRE4EbnocIOM28LZQuTCCA18wggJH
# oAMCAQICCwQAAAAAASFYUwiiMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNVBAsTF0ds
# b2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWduMRMwEQYD
# VQQDEwpHbG9iYWxTaWduMB4XDTA5MDMxODEwMDAwMFoXDTI5MDMxODEwMDAwMFow
# TDEgMB4GA1UECxMXR2xvYmFsU2lnbiBSb290IENBIC0gUjMxEzARBgNVBAoTCkds
# b2JhbFNpZ24xEzARBgNVBAMTCkdsb2JhbFNpZ24wggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDMJXaQeQZ4Ihb1wIO2hMoonv0FdhHFrYhy/EYCQ8eyip0E
# XyTLLkvhYIJG4VKrDIFHcGzdZNHr9SyjD4I9DCuul9e2FIYQebs7E4B3jAjhSdJq
# Yi8fXvqWaN+JJ5U4nwbXPsnLJlkNc96wyOkmDoMVxu9bi9IEYMpJpij2aTv2y8go
# keWdimFXN6x0FNx04Druci8unPvQu7/1PQDhBjPogiuuU6Y6FnOM3UEOIDrAtKeh
# 6bJPkC4yYOlXy7kEkmho5TgmYHWyn3f/kRTvriBJ/K1AFUjRAjFhGV64l++td7dk
# mnq/X8ET75ti+w1s4FRpFqkD2m7pg5NxdsZphYIXAgMBAAGjQjBAMA4GA1UdDwEB
# /wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSP8Et/qC5FJK5NUPpj
# move4t0bvDANBgkqhkiG9w0BAQsFAAOCAQEAS0DbwFCq/sgM7/eWVEVJu5YACUGs
# sxOGhigHM8pr5nS5ugAtrqQK0/Xx8Q+Kv3NnSoPHRHt44K9ubG8DKY4zOUXDjuS5
# V2yq/BKW7FPGLeQkbLmUY/vcU2hnVj6DuM81IcPJaP7O2sJTqsyQiunwXUaMld16
# WCgaLx3ezQA3QY/tRG3XUyiXfvNnBB4V14qWtNPeTCekTBtzc3b0F5nCH3oO4y0I
# rQocLP88q1UOD5F+NuvDV0m+4S4tfGCLw0FREyOdzvcya5QBqJnnLDMfOjsl0oZA
# zjsshnjJYS8Uuu7bVW/fhO4FCU29KNhyztNiUGUe65KXgzHZs7XKR1g/XzGCAokw
# ggKFAgEBMGswWzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gU0hBMjU2
# IC0gRzICDDOQIHdhxCbdlFADDTANBglghkgBZQMEAgEFAKCB8DAaBgkqhkiG9w0B
# CQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIDJb/IiglMaEY9MPbi/o
# K/GJlK+YmheW1kRkwpw/7p5gMIGgBgsqhkiG9w0BCRACDDGBkDCBjTCBijCBhwQU
# rmsC2QsljAmRsRYSid62aVY5HW8wbzBfpF0wWzELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gU0hBMjU2IC0gRzICDDOQIHdhxCbdlFADDTANBgkqhkiG9w0B
# AQEFAASCAQA1yp8frMBrW0ISQb3vQ9r2tRhYwCuWuUQaRJEdTw1JthO3+dxsAAg+
# L5S85P+Si+Or/ObaLBi5oCoIG+jQoHGwOv2CDUQSrq/FYj4/ilc8VYvkNRxYEGlp
# Vc/kvi97DJRiJ7gSGsKlujPIcxCM3ZSqe1cBSrr3I5zWnXuFMzzGRQxlSvqiQBMC
# gdl8CqZ9JILpmcGP/I+2nAEwkFiJTc2PVvddEfrVBWSBrPQ5ewNYRqAgZvnFJxKR
# WsNn5yWwixBjsRb+tv8WH1kYISsa5ox+Co+EtaXv2Ek+I/OcsP6N9Q7opKdjQFl1
# d2vRB38mdClaFRwusPuN/H0H7Py5yLRM
# SIG # End signature block
