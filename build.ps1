$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputDir = Join-Path $ProjectRoot 'output\pdf'

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
Push-Location $ProjectRoot
try {
    $Chapters = @(
        @{ Source = 'main'; Target = 'chapter-01-cn.pdf' },
        @{ Source = 'chapter02'; Target = 'chapter-02-cn.pdf' }
    )
    foreach ($Chapter in $Chapters) {
        $SourceFile = "$($Chapter.Source).tex"
        xelatex -interaction=nonstopmode -halt-on-error $SourceFile
        if ($LASTEXITCODE -ne 0) { throw "First LaTeX pass failed: $SourceFile" }
        xelatex -interaction=nonstopmode -halt-on-error $SourceFile
        if ($LASTEXITCODE -ne 0) { throw "Second LaTeX pass failed: $SourceFile" }
        Move-Item -Force -LiteralPath (Join-Path $ProjectRoot "$($Chapter.Source).pdf") -Destination (Join-Path $OutputDir $Chapter.Target)
    }
} finally {
    Pop-Location
}
