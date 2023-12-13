Import-Module jsonify -force -PassThru

$file = Get-item $PSCommandPath
$folder = get-ITem $PSScriptRoot


# $file | ConvertTo-Json -compress -depth 1
# $folder| ConvertTo-Json -compress -depth 1
