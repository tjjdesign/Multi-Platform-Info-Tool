#Basic powershell script. Start with working it for just windows systems.
#Ideally this could work on linux as well, since powershell core will install with "apt-get install -y powershell"

$outfile = "system.info"

[PSCustomObject]@{ComputerName = $env:COMPUTERNAME} | Out-File -FilePath $outfile

Get-NetIPAddress -AddressFamily IPv4 | Select-Object IPAddress | Out-File -FilePath $outfile -Append

Get-ChildItem -Path "C:\Users" | Select-Object @{Name="Users in C:\Users"; Expression = {($_.Name)}} | Out-File -FilePath $outfile -Append

$openports = Get-NetTCPConnection -State Listen, Established 

[System.Collections.ArrayList]$portoutput = @()

foreach ($port in $openports) {
    $processinfo = Get-Process -Id $port.OwningProcess
    $PortTable = [PSCustomObject]@{
        LocalPort = $port.LocalPort
        RemotePort = $port.RemotePort
        ProcessName = $processinfo.Name
        Company = $processinfo.Company
    }

    [void]$portoutput.Add($PortTable)
}

$portoutput | Out-File -FilePath $outfile -Append

#checking registries for programs. this probably will not work at all on linux.
[System.Collections.ArrayList]$programoutput = @()

$baseregpath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

$registryentries = Get-ChildItem -Path $baseregpath

foreach($registry in $registryentries) {

    $reginfo = $registry | Get-ItemProperty  | Select-Object DisplayName, DisplayVersion, @{Name="Program Comments"; expression = {$_ | Select-Object -ExpandProperty Comments}}
    #$fullcomment = Get-ChildItem -Path $baseregpath

    if ($reginfo.DisplayName -ne $null) {
            [void]$programoutput.Add($reginfo)
        }
        
}

$programoutput | Out-File -FilePath $outfile -Append
