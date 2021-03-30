task CompressModulesWithChecksum {

    if ($SkipCompressedModulesBuild)
    {
        Write-Host 'Skipping preparation of Compressed Modules as $SkipCompressedModulesBuild is set'
        return
    }

    if (-not (Test-Path -Path $BuildOutput\CompressedModules)) {
        mkdir -Path $BuildOutput\CompressedModules | Out-Null
    }

    if ($SkipCompressedModulesBuild)
    {
        Write-Host 'Skipping preparation of Compressed Modules as $SkipCompressedModulesBuild is set'
        return
    }

    if ($configurationData.AllNodes -and $CurrentJobNumber -eq 1) {

        $modules = Get-ModuleFromFolder -ModuleFolder $ResourcesFolder
        $compressedModulesPath = "$BuildOutput\CompressedModules"

        foreach ($module in $modules) {
            $destinationPath = Join-Path -Path $compressedModulesPath -ChildPath "$($module.Name)_$($module.Version).zip"

            if (-not (Test-Path -Path C:\Temp\Module)) {
                $null = New-Item -Path C:\Temp\Module -ItemType Directory
            }

            # Need to copy the files before compressing in case a file is locked
            # Like if a .dll is loaded
            Get-ChildItem -Path $module.ModuleBase | Copy-Item -Destination C:\Temp\Module -Recurse
            Compress-Archive -Path C:\Temp\Module\* -DestinationPath $destinationPath
            Remove-Item -Path C:\Temp\Module\* -Recurse

            $hash = (Get-FileHash -Path $destinationPath).Hash

            try {
                $stream = New-Object -TypeName System.IO.StreamWriter("$destinationPath.checksum", $false)
                [void] $stream.Write($hash)
            }
            finally {
                if ($stream) {
                    $stream.Close()
                }
            }
        }
    }
    else {
        Write-Build Green "No data in 'ConfigurationData.AllNodes', skipping task 'CompressModulesWithChecksum'."
    }
}
