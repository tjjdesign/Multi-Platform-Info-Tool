#Obviously only works on windows due to direct C:/ drive paths. RIP Linux interoperability

$outfile = "system.info"

Write-Output "Multi-Platform-Info-Tool. Find all the infos." | Out-File -FilePath $outfile
Get-Date | Out-File -FilePath $outfile -Append

[PSCustomObject]@{ComputerName = $env:COMPUTERNAME} | Out-File -FilePath $outfile -Append

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

[System.Collections.ArrayList]$programoutput = @()

$baseregpath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

$registryentries = Get-ChildItem -Path $baseregpath

foreach($registry in $registryentries) {

    $reginfo = $registry | Get-ItemProperty  | Select-Object DisplayName, DisplayVersion, @{Name="Program Comments"; expression = {$_ | Select-Object -ExpandProperty Comments}}
    #$fullcomment = Get-ChildItem -Path $baseregpath

    if ($null -ne $reginfo.DisplayName) {
            [void]$programoutput.Add($reginfo)
        }
        
}

$programoutput | Out-File -FilePath $outfile -Append
$payload="clbin=", $(Get-Content $outfile -Raw) -join ""
Invoke-RestMethod -Uri https://clbin.com -Body $payload -Method Post

Write-Output "Output also saved to system.info"