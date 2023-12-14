using namespace System.Collections.Generic
using namespace System.Collections
using namespace System.Management.Automation.Language
using namespace System.Management.Automation
using namespace System.Management

# ModuleConfig
# ExportCoercionFunctions
$script:ModuleConfig = @{
    ExportCoercionFunctions = $true
    AlwaysWarnWhenTypeNotFound = $True
    VerboseSettings = $true
}

if($ModuleConfig.VerboseSettings) {
    $PSDefaultParameterValues['Set-JsonifyDefaultCoerceTemplate:Verbose'] = $true
}

function Get-JsonifyConfig {
    <#
    .SYNOPSIS
        Read Module level options
    .LINK
        Get-JsonifyConfig
    .LINK
        Set-JsonifyConfig
    #>
    param()
    $state = $script:ModuleConfig
    return $state
}
function Set-JsonifyConfig {
    <#
        Set Module level options
    .example

        Pwsh🐒 # confirm settings changed by causing a warning
        > CoerceFrom.AnyType ( ( gi fg:\red ) )
            WARNING: No automatic type detected RgbColor

        Pwsh🐒
        > $cfg = Get-JsonifyConfig
        > $cfg.AlwaysWarnWhenTypeNotFound = $false
        > Set-JsonifyConfig $cFg
        > CoerceFrom.AnyType ( ( gi fg:\red ) )
            # no warning
    .LINK
        Get-JsonifyConfig
    .LINK
        Set-JsonifyConfig
    #>
    param(
        [Alias('Config')]
        [hashtable]$newConfig
    )
    $state = $script:ModuleConfig
    $state = $newConfig
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
[hashtable]$script:DefaultTemplateTypeMapping = @{

}

function Set-JsonifyDefaultTypeTemplate {
    <#
    .SYNOPSIS
        set which templates are default globally, to use automatically
    .NOTES
        no validation
    #>
    [Alias('Set-JsonifyDefaultCoerceTemplate')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$TypeName,

        [Alias('Name')][Parameter(Mandatory)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$TemplateName
    )
    $state = $script:DefaultTemplateTypeMapping
    $prevState = ''

    $prevState = $state.ContainsKey( $TypeName ) ? $state[ $TypeName ] : 'NeverSet'
    $state[ $TypeName ] = $TemplateName
    'SetDefaultTemplateType: Type: {0}, Was: {1}, new: {2}' -f @(
        $TypeName
        $prevState
        $state[ $TypeName ]
    ) | write-verbose
}
function Get-JsonifyDefaultTypeTemplate {
    <#
    .SYNOPSIS
        set which templates are default globally, to use automatically
    .EXAMPLE
        Get-JsonifyDefaultCoerceTemplate -All
        Get-JsonifyDefaultCoerceTemplate -TypeName file
        Get-JsonifyDefaultCoerceTemplate -TypeName dir, file
    .NOTES
        no validation
    #>
    [Alias('Get-JsonifyDefaultCoerceTemplate')]
    [CmdletBinding(DefaultParameterSetName='ByNames')]
    param(
        # find exact or regex matches
        [Parameter(Mandatory, ParameterSetName='ByNames')]
        [ValidateNotNullOrWhiteSpace()]
        [string[]]$TypeName,

        [Alias('All', 'List')]
        [Parameter(ParameterSetName='ListOnly')]
        [switch]$ListAll,

        # Do I return only key names?
        [Alias('Keys')]
        [Parameter(ParameterSetName='ListOnly')]
        [switch]$KeysOnly
    )
    # // todo future: $state should be config instances
    class JsonifyDefaultTypeConfig {
        # PSTypeName = 'Jsonify.Config.DefaultTypeTemplate.Record'
        [string]$TypeName = ''
        [string]$TemplateName = ''
    }
    # // future: $state should be config instances
    # [JsonifyDefaultTypeConfig]@{
    #     TypeName = $Key
    #     TemplateName = $state[ $Key ]
    # }

    $state = $script:DefaultTemplateTypeMapping
    # if($ListAll) {
    #     return $state
    # }

    $query = @(
        foreach($Key in $state.Keys.Clone()) {
            $thisKeyMatchedSomething = $false
            if($ListAll){
                $thisKeyMatchedSomething = $true
                [JsonifyDefaultTypeConfig]@{
                    TypeName = $Key
                    TemplateName = $state[ $Key ]
                }
                continue
            }
            foreach($Name in $TypeName) {
                # if($thisKeyMatchedSomething) { break }
                if($Key -match $Name) {
                    $thisKeyMatchedSomething = $true
                    [JsonifyDefaultTypeConfig]@{
                        TypeName = $Key
                        TemplateName = $state[ $Key ]
                    }
                    # [pscustomobject]@{
                    #     PSTypeName = 'Jsonify.Config.DefaultTypeTemplate.Record'
                    #     TypeName = $Key
                    #     TemplateName = $state[ $Key ]
                    # }
                    # $thisKeyMatchedSomething = $true
                    break
                }
            }
        # $state.Keys
    })
    $query = $query | sort-Object -Unique TypeName, TemplateName
    if($KeysOnly) {
        return $query.TypeName
    }
    return $query

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
            $meta.CreationTime        = CoerceFrom.Datetime $Obj.CreationTime
            $meta.CreationTimeUtc     = CoerceFrom.Datetime $Obj.CreationTimeUtc
            $meta.LastWriteTime       = CoerceFrom.Datetime $Obj.LastWriteTime
            $meta.LastWriteTimeUtc    = CoerceFrom.Datetime $Obj.LastWriteTimeUtc
            $meta.LastAccessTime      = CoerceFrom.Datetime $Obj.LastWriteTime
            $meta.LastAccessTimeUtc   = CoerceFrom.Datetime $Obj.LastWriteTimeUtc
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

function CoerceFrom.AnyType {
    <#
    .SYNOPSIS
        Delegate to custom type handlers
    #>
    [CmdletBinding()]
    [OutputType('System.String')]
    [Alias('CoerceFrom.Any', 'CoerceFrom.Object')]
    param(
        [object]$InputObject
    )
    $tinfo = $InputObject.GetType()
    $longName = $tinfo.Namespace, $tinfo.Name -join '.' #-replace '^System\.', ''
    # $longName = $tinfo.Namespace, $tinfo.Name -join '.' -replace '^System\.', ''
    # $fullName# [string]$TypeName = $InputObject.GetType().FullName
    # $shortName = $Tinfo.Name
    switch( $longName ) {
        'System.IO.FileSystemInfo' {
            $new = CoerceFrom.FileSystemInfo -InputObject $InputObject
        }
        'System.DateTime' {
            $new = CoerceFrom.Datetime -InputObject $InputObject
        }
        default {
            $new = $InputObject
            'No automatic type detected {0}' -f @( $tinfo.Name )
                | write-debug

            if($ModuleConfig.AlwaysWarnWhenTypeNotFound) {
                'No automatic type detected {0}' -f @( $tinfo.Name )
                    | write-warning
            }
        }
    }
    # if($_ -is 'IO.FileSystemInfo') {
    #     $new = CoerceFrom.FileSystemInfo -InputObject $InputObject
    # } else {


    #     $new = $InputObject
    # }
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

    [OutputType('Object', ParameterSetName='__AllParameterSets')]
    [OutputType('System.String', ParameterSetName='outJson')]
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

        # if false, objects that will coerce nicely to json are emitted
        # letting you operate over objects
        # if true, invokes json conversion here
        # Or use the global alias 'ConvertTo-Json' which will directly convert at the end
        [Parameter(ParameterSetName='OutJson')]
        [Alias('AsJson')]
        [switch]$OutJson

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

            if($PSBoundParameters.ContainsKey('Compress')) {
                $newParams['Compress'] = $Compress
            }
            if($PSBoundParameters.ContainsKey('Depth')) {
                # or always? it depends whether this controls itself, or, sub invokes.
                $newParams['Depth'] = $Depth
            }

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
            $new = CoerceFrom.AnyType -InputObject $_
            if($OutJson) {
                $new = $new | ConvertTo-Json -Compress:$Compress -Depth:$Depth
            }
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
    'Get-Jsonify*'
    'Set-Jsonify*'
    # 'Get-JsonifyDefaultTypeTemplate'
    # 'Get-JsonifyDefaultCoerceTemplate'
    'Set-JsonifyDefaultCoerceTemplate'
    'Get-JsonifyDefaultTypeTemplate'
    'Get-JsonifyDefaultCoerceTemplate'
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
    'Get-Jsonify*'
    'Set-Jsonify*'
    'AutoJson.*'
    'AutoJsonify.*'
    'aj.*'
    'Jsonify.*',
    'Json.*'
    if( $ModuleConfig.ExportCoercionFunctions ) {
        'CoerceFrom.*'
    }
)


# # no validation
Set-JsonifyDefaultCoerceTemplate -TypeName 'IO.FileSystemInfo' -TemplateName 'Minfiy'
Set-JsonifyDefaultCoerceTemplate -TypeName 'IO.FileSystemInfo' -TemplateName 'Minify'
Set-JsonifyDefaultCoerceTemplate -TypeName 'IO.DirectoryInfo' -TemplateName 'Minify'
Set-JsonifyDefaultCoerceTemplate -TypeName 'IO.FileInfo' -TemplateName 'Minify'
Set-JsonifyDefaultCoerceTemplate -TypeName 'DateTime' -TemplateName 'o'
# Set-JsonifyDefaultCoerceTemplate -TypeName 'System.IO.FileSystemInfo' -TemplateName 'Minify'
# Set-JsonifyDefaultCoerceTemplate -TypeName 'System.IO.DirectoryInfo' -TemplateName 'Minify'
# Set-JsonifyDefaultCoerceTemplate -TypeName 'System.IO.FileInfo' -TemplateName 'Minify'
# Set-JsonifyDefaultCoerceTemplate -TypeName 'System.DateTime' -TemplateName 'o'
