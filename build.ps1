$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputDir = Join-Path $ProjectRoot 'output/pdf'
$BuildDir = Join-Path $ProjectRoot ('tmp/build.' + [Guid]::NewGuid().ToString('N'))

Push-Location $ProjectRoot
try {
    New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
    $Chapters = @(
        @{ Source = 'main'; Target = 'chapter-01-cn.pdf' },
        @{ Source = 'chapter02'; Target = 'chapter-02-cn.pdf' },
        @{ Source = 'chapter03'; Target = 'chapter-03-cn.pdf' },
        @{ Source = 'chapter04'; Target = 'chapter-04-cn.pdf' },
        @{ Source = 'chapter05'; Target = 'chapter-05-cn.pdf' },
        @{ Source = 'complete'; Target = 'complete-cn.pdf' }
    )
    foreach ($Chapter in $Chapters) {
        $SourceFile = "$($Chapter.Source).tex"
        foreach ($Pass in 1..3) {
            xelatex -interaction=nonstopmode -halt-on-error "-output-directory=$BuildDir" $SourceFile
            if ($LASTEXITCODE -ne 0) { throw "LaTeX pass $Pass failed: $SourceFile" }
        }
        $Pdf = Join-Path $BuildDir "$($Chapter.Source).pdf"
        if (!(Test-Path -LiteralPath $Pdf -PathType Leaf) -or (Get-Item -LiteralPath $Pdf).Length -eq 0) {
            throw "Compiler did not generate $($Chapter.Source).pdf"
        }
    }
    # Publish only after every document has compiled successfully.
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    foreach ($Chapter in $Chapters) {
        Copy-Item -Force -LiteralPath (Join-Path $BuildDir "$($Chapter.Source).pdf") -Destination (Join-Path $OutputDir $Chapter.Target)
    }
} finally {
    Remove-Item -Recurse -Force -LiteralPath $BuildDir -ErrorAction SilentlyContinue
    Pop-Location
}
