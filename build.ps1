$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputDir = Join-Path $ProjectRoot 'output\pdf'

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
Push-Location $ProjectRoot
try {
    xelatex -interaction=nonstopmode -halt-on-error main.tex
    xelatex -interaction=nonstopmode -halt-on-error main.tex
    Move-Item -Force -LiteralPath (Join-Path $ProjectRoot 'main.pdf') -Destination (Join-Path $OutputDir 'chapter-01-cn.pdf')
} finally {
    Pop-Location
}
