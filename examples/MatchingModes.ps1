Import-Module (Join-Path $PSScriptRoot '../Jsonify/Jsonify.psm1')  -force -PassThru
    | Render.ModuleName
Set-Alias 'Json.Original' -Value Microsoft.PowerShell.Utility\ConvertTo-Json

$file = Get-Item $PSCommandPath
$folder = Get-Item $PSScriptRoot
$sharedJson = @{
    Compress = $True
    WarningAction = 'ignore'
}


Set-JsonifyDefaultTypeTemplate -Verb -TypeName 'IO.FileSystemInfo' 'Minify'
Set-JsonifyDefaultTypeTemplate -Verb -TypeName 'DateTimeOffset' 'YearMonthDay'
Get-JsonifyDefaultTypeTemplate -List
