## About

Different ways to search for type templates

```ps1
Pwsh🐒
> Get-JsonifyDefaultTypeTemplate -TypeName 'file'

    TypeName          TemplateName MatchKind
    --------          ------------ ---------
    IO.FileInfo       Minify       Regex
    IO.FileSystemInfo Minify       Regex

```

### Examples

- Regex is implicit
- ExactMatch will always return first
- Or use `-Wildcard` for `-like` matching

```ps1
Get-JsonifyDefaultTypeTemplate 'DateTime'

TypeName       TemplateName MatchKind
--------       ------------ ---------
DateTime       o            Exact
DateTimeOffset YearMonthDay Regex

Pwsh 7.4.0> 🐒
Get-JsonifyDefaultTypeTemplate 'DateTime' -UsingWildcard

TypeName TemplateName MatchKind
-------- ------------ ---------
DateTime o            Exact

Pwsh 7.4.0> 🐒
Get-JsonifyDefaultTypeTemplate 'DateTime*' -UsingWildcard

TypeName       TemplateName MatchKind
--------       ------------ ---------
DateTime       o            Wildcard
DateTimeOffset YearMonthDay Wildcard
```

### Examples

```ps1
Get-JsonifyDefaultTypeTemplate -TypeName 'IO.FileInfo'


TypeName    TemplateName MatchKind
--------    ------------ ---------
IO.FileInfo Minify       Exact


Pwsh 7.4.0> 🐒
Get-JsonifyDefaultTypeTemplate -TypeName 'IO.FileInfo.*'

TypeName    TemplateName MatchKind
--------    ------------ ---------
IO.FileInfo Minify       Regex

Pwsh 7.4.0> 🐒
Get-JsonifyDefaultTypeTemplate -TypeName 'IO.FileInfo'  

TypeName    TemplateName MatchKind
--------    ------------ ---------
IO.FileInfo Minify       Exact
```

