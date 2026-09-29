#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p output/pdf

build_chapter() {
  local source="$1"
  local target="$2"
  local build_dir="tmp/build/$source"
  mkdir -p "$build_dir"
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
  cp "$build_dir/$source.pdf" "output/pdf/$target"
}

build_chapter main chapter-01-cn.pdf
build_chapter chapter02 chapter-02-cn.pdf
