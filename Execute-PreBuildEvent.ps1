param(
    [string]$SolutionDir=$(throw "Parameter missing: -SolutionDir"),
    [string]$ProjectPath=$(throw "Parameter missing: -ProjectPath"),
    [string]$Configuration=$(throw "Parameter missing: -Configuration"),
    [string]$TargetDir=$(throw "Parameter missing: -TargetDir"),
    [string]$TargetPath=$(throw "Parameter missing: -TargetPath")
)

Write-Host "Detecting DX SDK..."

if ($env:DXSDK_DIR -eq $null) {
    $host.SetShouldExit(1)
    Exit-PSHostProcess
}

$compilerPath = Join-Path $env:DXSDK_DIR "Utilities\bin\x86\fxc.exe"

Write-Host "Detecting compiler..."

if (-not (Test-Path $compilerPath)) {
    $host.SetShouldExit(1)
    Exit-PSHostProcess
}

$targetLastWriteTime = $null

if (Test-Path $TargetPath) {
    $targetLastWriteTime = (Get-Item $TargetPath).LastWriteTime
}

$effectsDir = Join-Path $SolutionDir "src\Sakuno.UserInterface\Media\Effects"

Write-Host "Compiling effect files..."

foreach ($file in Get-ChildItem $effectsDir -Filter "*.fx") {
    if ($null -eq $targetLastWriteTime -or $file.LastWriteTime -gt $targetLastWriteTime) {
        Write-Host "Compiling $file"

        $outputPath = Join-Path $file.Directory.FullName ($file.Basename + ".ps")

        & $compilerPath "/T", "ps_3_0", "/E", "main", "/Fo", $outputPath, $file.FullName

        if ($LASTEXITCODE -ne 0) {
            $host.SetShouldExit($LASTEXITCODE)
            Exit-PSHostProcess
        }
    }
}

Write-Host "Finished."