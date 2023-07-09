Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)


function InstallVS {
    param(
        [string]$mail
    )

    if ($mail.Contains('microsoft')) {
        Install-IfNotInstalled Microsoft.VisualStudio.2022.Enterprise
    }
    else {
        Install-IfNotInstalled Microsoft.VisualStudio.2022.Community
    }
    
}

Export-ModuleMember -Function InstallVS