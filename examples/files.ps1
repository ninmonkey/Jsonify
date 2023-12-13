impo Jsonify -force -PassThru

# [Text.StringBuilder]$Sb = ''
# return
$file = Get-item $PSCommandPath
$folder = get-ITem $PSScriptRoot

$file | ConvertTo-Json -compress -depth 3
$folder| ConvertTo-Json -compress -depth 3

h1 'for files, even depth 1/0 is huge'
$file|ConvertTo-Json -Depth 1 -Compress


'and now'
