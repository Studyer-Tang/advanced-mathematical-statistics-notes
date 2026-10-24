#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p tmp
build_dir=$(mktemp -d tmp/build.XXXXXXXX)
trap 'rm -rf -- "$build_dir"' EXIT

build_chapter() {
  local source="$1"
  if command -v latexmk >/dev/null 2>&1; then
    latexmk -xelatex -interaction=nonstopmode -halt-on-error -outdir="$build_dir" "$source.tex"
  elif command -v xelatex >/dev/null 2>&1; then
    for pass in 1 2 3; do
      xelatex -interaction=nonstopmode -halt-on-error -output-directory="$build_dir" "$source.tex"
    done
  elif command -v tectonic >/dev/null 2>&1; then
    tectonic -X compile "$source.tex" --outdir "$build_dir" --keep-logs
  else
    echo "Install XeLaTeX with ctex, or Tectonic, before building." >&2
    exit 1
  fi
  if [[ ! -s "$build_dir/$source.pdf" ]]; then
    echo "Compiler did not generate $source.pdf." >&2
    exit 1
  fi
}

# Compile the entire edition before replacing published PDFs.
sources=(main chapter02 chapter03 chapter04 chapter05 complete)
targets=(chapter-01-cn chapter-02-cn chapter-03-cn chapter-04-cn chapter-05-cn complete-cn)
for source in "${sources[@]}"; do
  build_chapter "$source"
done
mkdir -p output/pdf
for index in "${!sources[@]}"; do
  cp "$build_dir/${sources[$index]}.pdf" "output/pdf/${targets[$index]}.pdf"
done
