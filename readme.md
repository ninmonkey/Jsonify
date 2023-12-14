- [About](#about)
- [Example](#example)
  - [Choosing the Global Default Templates](#choosing-the-global-default-templates)
  - [Getting Global Default Templates](#getting-global-default-templates)
  - [Explicitly Choosing Templates](#explicitly-choosing-templates)


## About

Do you wish `ConvertTo-Json` gave shorter, simpler output by default? *And* without using `-Depth`? Then Jsonify is for you.

Regular `ConvertTo-Json` needs `-Depth` to keep Json from exploding. 
`Jsonify` takes a different route.

- Check TypeNames of your objects. 
- If it's simple keep it
- If it's known types, simplify their properties 
- You can go deeper with simple types and still get smaller json as output
- Choose your favorite templates based on typenames
  
One goal is making json 'clean' enough that you can use it in an interactive session without drowning. 

## Example

Comparing default sizes 
```ps1
Pwsh7🐒
> (gi .| Json -Compress).Length
  WARNING: Resulting JSON is truncated as serialization has exceeded the set depth of 2.
  30176

Pwsh7🐒
> (CoerceFrom.FileSystemInfo (gi .) -TemplateName Minify | Json -Compress).Length
  133
```

### Choosing the Global Default Templates

```ps1
Pwsh7🐒
> Set-JsonifyDefaultCoerceTemplate -TypeName 'File' -TemplateName 'Minify'
> Set-JsonifyDefaultCoerceTemplate -TypeName 'Datetime' -TemplateName 'o'
```

### Getting Global Default Templates

```ps1
Pwsh7🐒
> Get-JsonifyDefaultCoerceTemplate -ListAll

    TypeName          TemplateName
    --------          ------------
    DateTime          o
    IO.DirectoryInfo  Minify
    IO.FileInfo       Basic
    IO.FileSystemInfo Minify

```

### Explicitly Choosing Templates 

```ps1
Pwsh7🐒
> CoerceFrom.FileSystemInfo (gi .) -TemplateName Minify

    Name    FullName                            Length LastWriteTimeUtc
    ----    --------                            ------ ----------------
    Jsonify H:\data\2023\pwsh\PsModules\Jsonify      1 2023-12-13T23:24:44.8180199Z

Pwsh7🐒
> CoerceFrom.FileSystemInfo (gi .) -TemplateName Basic 
    
    TypeName            : DirectoryInfo
    Name                : Jsonify
    BaseName            : Jsonify
    FullName            : H:\data\2023\pwsh\PsModules\Jsonify
    Length              : 1
    CreationTime        : 2023-11-22T13:01:14.4645141-06:00
    CreationTimeUtc     : 2023-11-22T19:01:14.4645141Z
    LastWriteTime       : 2023-12-13T17:24:44.8180199-06:00
    LastWriteTimeUtc    : 2023-12-13T23:24:44.8180199Z
    LastAccessTimeUtc   : 2023-12-13T23:24:44.8180199Z
    Extension           : 
    LinkTarget          : 
    LinkType            : 
    ModeWithoutHardLink : d----
    Parent              : H:\data\2023\pwsh\PsModules
    Root                : H:\
  ```