using namespace System.Collections.Generic
using namespace System.Collections
using namespace System.Management.Automation.Language
using namespace System.Management.Automation
# using namespace System.Management
class SummarizePropertyRecord {
    [PSMemberTypes]$MemberType = [PSMemberTypes]::All
    [object]$FullName
    [string]$ShortName

    # SummarizePropertyRecord( $Options ) {

    # }
}
function js.Summarize.SingleProperty {
    param(
        $InputObject
    )

    $meta = @{
        Name = 'Name'
        MemberKind =
    }
    [PSMemberTypes]

    [pscustomobject]$meta
}

function js.DescribeType {
    param(
        $InputObject
    )
    $Obj = $InputObject
    $TrueNull = $Null = $Obj
    $Tinfo = ($Obj)?.GetType()

    $meta = [ordered]@{
        PSTypeName = 'jsonify.{0}.Record' -f $MyInvocation.MyCommand.Name
        Count = $Obj.Count
        Len = $Obj.Length
        Is = [ordered]@{
            Null = $Null -eq $Obj
            EmptyStr = [String]::IsNullOrEmpty( $Obj )
            Blank = [String]::IsNullOrWhiteSpace( $Obj )
            Array = 'nyi'
        }
        Implements = [ordered]@{
            IList = 'nyi'
            ICollection = 'nyi'
            IEnumerable = 'nyi'

        }
        Value = $InputObject
        PropsFromType = [List[Object]]::New()
        PropsFromObject = [List[Object]]::New()
    }


    [pscustomobject]$Meta

    # update-typedata to hide Value ?

}
function Jsonify.CoerceType {
    param(
        $InputObject
    )
}

function Jsonify.GetCommands {
    param(
        $InputObject
    )
    gcm -m Ninmonkey.Console *jsonif* -ea 'ignore'
        | Join-string -sep ', ' -op 'see also: Ninmonkey.Console\ => [ ' -os ' ] '
        | Write-verbose -verbose
}

Export-ModuleMember -Function @(
    'Jsonify.*',
    'Json.*'
) -Alias @(
    'Jsonify.*',
    'Json.*'
)
