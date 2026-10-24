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
    xelatex -interaction=nonstopmode -halt-on-error -output-directory="$build_dir" "$source.tex"
    xelatex -interaction=nonstopmode -halt-on-error -output-directory="$build_dir" "$source.tex"
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

# A compilation failure must not publish only one chapter of a new edition.
build_chapter main
build_chapter chapter02
mkdir -p output/pdf
cp "$build_dir/main.pdf" output/pdf/chapter-01-cn.pdf
cp "$build_dir/chapter02.pdf" output/pdf/chapter-02-cn.pdf
