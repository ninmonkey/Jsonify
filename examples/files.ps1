# impo Jsonify -force -PassThru
Import-Module (Join-Path $PSScriptRoot '../Jsonify/Jsonify.psm1')  -force -PassThru
    | Render.ModuleName
Set-Alias 'Json.Original' -Value Microsoft.PowerShell.Utility\ConvertTo-Json


$file = Get-item $PSCommandPath
$folder = get-ITem $PSScriptRoot

$cache = @{}
$cache.File_D3   ??= $file | ConvertTo-Json -compress -depth 3
$cache.File_D1   ??= $file | ConvertTo-Json -compress -depth 1
$cache.Folder_D3 ??= $Folder | ConvertTo-Json -depth 3
$cache.Folder_D1 ??= $Folder | ConvertTo-Json -depth 1
$cache.Folder_D0 ??= $Folder | ConvertTo-Json -depth 0

h1 'for files, even depth 1/0 is huge'

@(foreach($Item in $cache.GetEnumerator()) {
    [pscustomobject]@{
        Name   = ($Item.Key -split '_')[0]
        Depth  = ($Item.Key -split '_')[-1] -replace '\D', ''
        JsonLength = $Item.Value.Length
    }
})
| Sort-Object Length -Descending
| Ft -auto
