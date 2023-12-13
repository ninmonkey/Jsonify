using namespace System.Collections.Generic
using namespace System.Collections
using namespace System.Management.Automation.Language
using namespace System.Management.Automation
using namespace System.Management

$script:ModuleConfig = @{
    ExportCoercionFunctions = $true
}
# class SummarizePropertyRecord {
#     [PSMemberTypes]$MemberType = [PSMemberTypes]::All
#     [object]$FullName
#     [string]$ShortName

#     # SummarizePropertyRecord( $Options ) {

#     # }
# }
# function js.Summarize.SingleProperty {
#     param(
#         $InputObject
#     )

#     $meta = @{
#         Name = 'Name'
#         MemberKind =
#     }
#     [PSMemberTypes]

#     [pscustomobject]$meta
# }

# function js.DescribeType {
#     param(
#         $InputObject
#     )
#     $Obj = $InputObject
#     $TrueNull = $Null = $Obj
#     $Tinfo = ($Obj)?.GetType()

#     $meta = [ordered]@{
#         PSTypeName = 'jsonify.{0}.Record' -f $MyInvocation.MyCommand.Name
#         Count = $Obj.Count
#         Len = $Obj.Length
#         Is = [ordered]@{
#             Null = $Null -eq $Obj
#             EmptyStr = [String]::IsNullOrEmpty( $Obj )
#             Blank = [String]::IsNullOrWhiteSpace( $Obj )
#             Array = 'nyi'
#         }
#         Implements = [ordered]@{
#             IList = 'nyi'
#             ICollection = 'nyi'
#             IEnumerable = 'nyi'

#         }
#         Value = $InputObject
#         PropsFromType = [List[Object]]::New()
#         PropsFromObject = [List[Object]]::New()
#     }


#     [pscustomobject]$Meta

#     # update-typedata to hide Value ?

# }

function WarnIf.NotType {
    param(
        [Parameter(Mandatory)]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [string]$TypeName
    )
    if(-not( $InputObject -is $TypeName)) {
        'Jsonify: WarnIfNotType: expected {0} but found {1}' -f @(
            $TypeName
            $InputObject.GetType().Name
        ) | write-warning
    }
}

function CoerceFrom.Datetime {
    [OutputType('System.string')]
    param(
        [Parameter(mandatory, ValueFromPipeline)]
        [object]$InputObject,
        [Alias('IgnoreProp', 'DropProperty', 'Drop')]
        [string[]]$ExcludeProperty = @()
    )
    process {
        WarnIf.NotType $InputObject -type 'datetime'

        return $InputObject.ToString('o')
    }
}

function CoerceFrom.FileSystemInfo {
    [Alias('CoerceFrom.File')]
    param(
        [object]$InputObject,

        [ValidateSet(
            'Basic',
            'Minify'
        )]
        [string]$TemplateName = 'Basic',

        [Alias('IgnoreProp', 'DropProperty', 'Drop')]
        [string[]]$ExcludeProperty = @(
            'PSPath'
            'LastAccessTime'
            'Exists'
            # 'Extension'
            'PSChildName'
            'PSDrive'
            'PSIsContainer'
            'PSParentPath'
            'PSPath'
            'PSProvider'
            'ResolvedTarget'
            'Target'
            'UnixFileMode'
            'Attributes'
            'Mode'
            'IsReadOnly'
            # 'Length'
            'VersionInfo'
        )


    )
    $Obj = $InputObject
    $tinfo = $InputObject.GetType()
    $meta = [ordered]@{
        PSTypeName = 'Jsonify.File'
        TypeName = $Tinfo.Name
    }
    'AutoJson using TemplateName {0} on {1}' -f @( $TemplateName ; $Obj.GetType().Name )
            | write-verbose

    switch( $tinfo.FullName ) {
        { $_ -in @( 'System.IO.DirectoryInfo' ) } {
            # Shared props
            $meta.Name                = $Obj.Name.ToString()
            $meta.BaseName            = $Obj.Name.ToString()
            $meta.FullName            = $Obj.FullName.ToString()
            $meta.PSPath              = $Obj.PSPath.ToString()
            $meta.Length              = $Obj.Length
            $meta.CreationTime        = AutoJsonify.From.Datetime $Obj.CreationTime
            $meta.CreationTimeUtc     = AutoJsonify.From.Datetime $Obj.CreationTimeUtc
            $meta.LastWriteTime       = AutoJsonify.From.Datetime $Obj.LastWriteTime
            $meta.LastWriteTimeUtc    = AutoJsonify.From.Datetime $Obj.LastWriteTimeUtc
            $meta.LastAccessTime      = AutoJsonify.From.Datetime $Obj.LastWriteTime
            $meta.LastAccessTimeUtc   = AutoJsonify.From.Datetime $Obj.LastWriteTimeUtc
            $meta.Attributes          = [string]$Obj.Attributes
            $meta.Exists              = [string]$Obj.Exists
            $meta.Extension           = [string]$Obj.Extension
            $meta.LinkTarget          = [string]$Obj.LinkTarget
            $meta.LinkType            = [string]$Obj.LinkType
            $meta.Mode                = [string]$Obj.Mode
            $meta.ModeWithoutHardLink = [string]$Obj.ModeWithoutHardLink
            $meta.PSChildName         = [string]$Obj.PSChildName
            $meta.PSDrive             = [string]$Obj.PSDrive
            $meta.PSIsContainer       = [string]$Obj.PSIsContainer
            $meta.PSParentPath        = [string]$Obj.PSParentPath
            $meta.PSPath              = [string]$Obj.PSPath
            $meta.PSProvider          = [string]$Obj.PSProvider
            $meta.ResolvedTarget      = [string]$Obj.ResolvedTarget
            $meta.Target              = [string]$Obj.Target
            $meta.UnixFileMode        = [string]$Obj.UnixFileMode
        }
        'System.IO.DirectoryInfo' {
            <#
             props built by command
                Dot.List.Contains ( aj.Props (get-item .) -NameOnly) (aj.Props (get-item .\get-item-auto.json) -NameOnly) A.NotIn.B
            #>
            $meta.Parent = [string]$Obj.Parent
            $meta.Root   = [string]$Obj.Root
        }
        'System.IO.FileInfo' {
            <#
            props built by command

            Dot.List.Contains ( aj.Props (get-item .) -NameOnly) (aj.Props (get-item .\get-item-auto.json) -NameOnly) A.NotIn.B
                Directory
                DirectoryName
                IsReadOnly
                Length
                VersionInfo
            #>
            $meta.Directory     = [string]$Obj.Directory
            $meta.DirectoryName = [string]$Obj.DirectoryName
            $meta.IsReadOnly    = [string]$Obj.IsReadOnly
            $meta.Length        = [string]$Obj.Length
            $meta.VersionInfo   = [string]$Obj.VersionInfo
        }
        default {
            throw "AutoJsonify.From.FilesSystemInfo::UnhandledType: $( $InputObject.GetType() )"
        }
    }


    switch($TemplateName) {
        'Basic' {
            #n o-op atm
        }
        'Minify' {
            # remove almost all properties
            $toRemove = $meta.Keys.clone().where{ $_ -notin @(
                'Name'
                'FullName'
                'Length'
                'LastWriteTimeUtc'
            ) }
            $ExcludeProperty =  @( $ExcludeProperty ; $toRemove )
            write-debug 'minify using template'
        }

        default { throw "UnhandledTemplateName: $TemplateName"}
    }

    # $simplfiy
    foreach($name in @( $ExcludeProperty )) {
        $meta.remove( $Name )
    }
    [pscustomobject]$meta
}

function Jsonify.CoerceType {
    <#
    .SYNOPSIS
        Delegate to custom type handlers
    #>
    [OutputType('System.String')]
    [Alias('CoerceFrom.Any')]
    param(
        [object]$InputObject
    )


    if($_ -is 'IO.FileSystemInfo') {
        $new = CoerceFrom.FileSystemInfo -InputObject $_
    } else {
        $new = $new
    }
    return $new
}

function Jsonify.GetCommands {
    param(
        $InputObject
    )
    gcm -m Ninmonkey.Console *jsonif* -ea 'ignore'
        | Join-string -sep ', ' -op 'see also: Ninmonkey.Console\ => [ ' -os ' ] '
        | Write-verbose -verbose

    (Get-module 'Jsonify' ).ExportedCommands | Join-String -sep ', ' -op 'Commands: '
        | write-Verbose
}

function ConvertTo-Jsonify {
    <#
    .SYNOPSIS
        core entry point for the proxy of ConvertTo-Json
    #>
    [Alias(
        'AutoJsonify', 'Jsonify', 'aj.Json'
    )]

    param(
        [Alias('Obj', 'Data', 'InpObj', 'In')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [AllowNull()]
        [Object]${InputObject},

        [ValidateRange(0, 100)]
        [int]${Depth} = 6,
        [switch]${Compress},
        [switch]${EnumsAsStrings} = $true,
        [switch]${AsArray} =  $true,

        #[Newtonsoft.Json.StringEscapeHandling]
        [ValidateSet( 'Default', 'EscapeNonAscii', 'EscapeHtml' )]
        ${EscapeHandling})

    begin {
        try {
            # $outBuffer = $null
            # if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
            #     $PSBoundParameters['OutBuffer'] = 1
            # }
            $newParams = [ordered]@{} + $PSBoundParameters
            $newParams['WarningAction'] = 'ignore'
            $commandName = 'Microsoft.PowerShell.Utility\ConvertTo-Json'
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
                <# commandName: #> $commandName,
                <# type: #> [CommandTypes]::Cmdlet )

            $scriptCmd = { & $wrappedCmd @newParams }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline(
                $myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            throw
        }
    }

    process {
        try {
            # write-verbose 'Aj.Json :: Process'
            $new = Jsonify.CoerceType -InputObject $_
            $steppablePipeline.Process( $new )
        }
        catch {
            throw
        }
    }

    end {
        # write-verbose 'Aj.Json :: End'
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }

    clean {
        if ($null -ne $steppablePipeline) {
            $steppablePipeline.Clean()
        }
    }
}

Export-ModuleMember -Function @(
    'ConvertTo-Jsonify'
    'AutoJson.*'
    'AutoJsonify.*'
    'aj.*'
    'Jsonify.*',
    'Json.*'

    if( $ModuleConfig.ExportCoercionFunctions ) {
        'CoerceFrom.*'
    }
) -Alias @(
    'AutoJson.*'
    'AutoJsonify.*'
    'aj.*'
    'Jsonify.*',
    'Json.*'
    if( $ModuleConfig.ExportCoercionFunctions ) {
        'CoerceFrom.*'
    }
)
