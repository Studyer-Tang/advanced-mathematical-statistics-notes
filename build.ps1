$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputDir = Join-Path $ProjectRoot 'output/pdf'
$BuildDir = Join-Path $ProjectRoot ('tmp/build.' + [Guid]::NewGuid().ToString('N'))

Push-Location $ProjectRoot
try {
    New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
    $Chapters = @(
        @{ Source = 'main'; Target = 'chapter-01-cn.pdf' },
        @{ Source = 'chapter02'; Target = 'chapter-02-cn.pdf' }
    )
    foreach ($Chapter in $Chapters) {
        $SourceFile = "$($Chapter.Source).tex"
        xelatex -interaction=nonstopmode -halt-on-error "-output-directory=$BuildDir" $SourceFile
        if ($LASTEXITCODE -ne 0) { throw "First LaTeX pass failed: $SourceFile" }
        xelatex -interaction=nonstopmode -halt-on-error "-output-directory=$BuildDir" $SourceFile
        if ($LASTEXITCODE -ne 0) { throw "Second LaTeX pass failed: $SourceFile" }
        $Pdf = Join-Path $BuildDir "$($Chapter.Source).pdf"
        if (!(Test-Path -LiteralPath $Pdf -PathType Leaf) -or (Get-Item -LiteralPath $Pdf).Length -eq 0) {
            throw "Compiler did not generate $($Chapter.Source).pdf"
        }
    }
    # Publish only after both chapters have compiled successfully.
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    foreach ($Chapter in $Chapters) {
        Copy-Item -Force -LiteralPath (Join-Path $BuildDir "$($Chapter.Source).pdf") -Destination (Join-Path $OutputDir $Chapter.Target)
    }
} finally {
    Remove-Item -Recurse -Force -LiteralPath $BuildDir -ErrorAction SilentlyContinue
    Pop-Location
}
