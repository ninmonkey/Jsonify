# impo Jsonify -force -PassThru
Import-Module (Join-Path $PSScriptRoot '../Jsonify/Jsonify.psm1')  -force -PassThru
    | Render.ModuleName
Set-Alias 'Json.Original' -Value Microsoft.PowerShell.Utility\ConvertTo-Json

$file = Get-Item $PSCommandPath
$folder = Get-Item $PSScriptRoot
$sharedJson = @{
    Compress = $True
    WarningAction = 'ignore'
}

<#
output:

    Name   Depth JsonLength
    ----   ----- ----------
    File   0           1618
    File   1           2970
    File   3         373007
    Folder 0           1014
    Folder 1           2584
    Folder 3         373325


    Name   Template JsonLength
    ----   -------- ----------
    File   Basic           173
    File   Minify           17
    Folder Basic           537
    Folder Minify          144
#>

$cache = @{}
$cache.File_D3   ??= $file | Json.Original @sharedJson -depth 3
$cache.File_D1   ??= $file | Json.Original @sharedJson -depth 1
$cache.File_D0   ??= $file | Json.Original @sharedJson -depth 0
$cache.Folder_D3 ??= $Folder | Json.Original @sharedJson -depth 3
$cache.Folder_D1 ??= $Folder | Json.Original @sharedJson -depth 1
$cache.Folder_D0 ??= $Folder | Json.Original @sharedJson -depth 0

$results_jsonify = [ordered]@{}
$results_jsonify.Folder_Basic =
    CoerceFrom.FileSystemInfo $folder  -TemplateName Basic | Json -Compress
$results_jsonify.Folder_Minify =
    CoerceFrom.FileSystemInfo $folder  -TemplateName Minify | Json -Compress
$results_jsonify.File_Basic =
    CoerceFrom.FileSystemInfo $File  -TemplateName Basic | Json -Compress
$results_jsonify.File_Minify =
    CoerceFrom.FileSystemInfo $File  -TemplateName Minify | Json -Compress

'for files, even -Depth 1/0 is huge' | write-warning

@(foreach($Item in $cache.GetEnumerator()) {
    [pscustomobject]@{
        Name   = ($Item.Key -split '_')[0]
        Depth  = ($Item.Key -split '_')[-1] -replace '\D', ''
        JsonLength = $Item.Value.Length
    }
})
| Sort-Object Name, Depth, JsonLength
| Ft -auto
@(foreach($Item in $results_jsonify.GetEnumerator()) {
    [pscustomobject]@{
        Name   = ($Item.Key -split '_')[0]
        Template  = ($Item.Key -split '_')[-1]
        JsonLength = $Item.Value.Length
    }
})
# | Sort-Object Length
| Sort-Object Name, Template, JsonLength
| Ft -auto
