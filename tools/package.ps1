$projectRoot = Split-Path $PSScriptRoot -Parent
$mapping = @(
    @{ Disk='src/shared'; Target='ReplicatedStorage.Neighborhood.Shared' },
    @{ Disk='src/server'; Target='ServerScriptService.Neighborhood' },
    @{ Disk='src/client'; Target='StarterPlayer.StarterPlayerScripts.Neighborhood' }
)
$scripts = foreach($map in $mapping) {
    $sourceRoot = Join-Path $projectRoot $map.Disk
    foreach($file in Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Filter '*.luau') {
        $relative = [IO.Path]::GetRelativePath($sourceRoot,$file.FullName).Replace('\','/')
        $class = if($relative.EndsWith('.server.luau')) {'Script'} elseif($relative.EndsWith('.client.luau')) {'LocalScript'} else {'ModuleScript'}
        $name = $relative -replace '\.(server|client)\.luau$','' -replace '\.luau$',''
        @{path=$map.Target+'.'+$name.Replace('/','.');class=$class;source=[IO.File]::ReadAllText($file.FullName)}
    }
}
ConvertTo-Json -InputObject @($scripts) -Depth 5 -Compress
