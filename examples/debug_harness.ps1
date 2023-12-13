Import-Module (Join-Path $PSScriptRoot '../Jsonify/Jsonify.psm1')  -force -PassThru
    | Render.ModuleName

$file = Get-item $PSCommandPath
$folder = get-ITem $PSScriptRoot


# $file | ConvertTo-Json -compress -depth 1
# $folder| ConvertTo-Json -compress -depth 1
