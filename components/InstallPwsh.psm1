Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path)


function InstallPwsh {
    Install-IfNotInstalled "Microsoft.PowerShell"
}

Export-ModuleMember -Function InstallPwsh
