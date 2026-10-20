"""Exercise publication and cleanup without installing a TeX distribution."""
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
FAKE_COMPILER = '''import os
from pathlib import Path
import sys
args = sys.argv[1:]
source = next(Path(arg).stem for arg in args if arg.endswith(".tex"))
if os.environ.get("FAIL_SOURCE") == source:
    sys.exit(1)
if os.environ.get("MISSING_SOURCE") == source:
    sys.exit(0)
output = Path(".")
for index, arg in enumerate(args):
    if arg.startswith(("-outdir=", "-output-directory=")):
        output = Path(arg.split("=", 1)[1])
    elif arg == "--outdir":
        output = Path(args[index + 1])
output.mkdir(parents=True, exist_ok=True)
(output / (source + ".pdf")).write_bytes(b"%PDF-1.5 new " + source.encode())
(output / (source + ".aux")).write_text("temporary")
'''


class BuildScriptChecks(unittest.TestCase):
    def build(self, backend, *, fail=None, missing=None):
        temporary = tempfile.TemporaryDirectory(prefix="notes build ")
        self.addCleanup(temporary.cleanup)
        project = Path(temporary.name)
        for name in ["build.sh", "build.ps1"]:
            shutil.copyfile(ROOT / name, project / name)
        (project / "main.tex").touch()
        (project / "chapter02.tex").touch()
        published = project / "output" / "pdf"
        published.mkdir(parents=True)
        for name in ["chapter-01-cn.pdf", "chapter-02-cn.pdf"]:
            (published / name).write_bytes(b"previous " + name.encode())
        # A stale earlier build must never be mistaken for a successful new one.
        stale = project / "tmp" / "build" / "chapter02"
        stale.mkdir(parents=True)
        (stale / "chapter02.pdf").write_bytes(b"stale pdf")
        bin_dir = project / "bin"
        bin_dir.mkdir()
        compiler = bin_dir / "compiler.py"
        compiler.write_text(FAKE_COMPILER, encoding="utf-8")
        if os.name == "nt":
            launcher = bin_dir / "xelatex.cmd"
            launcher.write_text(f'@"{sys.executable}" "{compiler}" %*\n', encoding="utf-8")
            command = ["pwsh", "-NoProfile", "-File", str(project / "build.ps1")]
            path = str(bin_dir) + os.pathsep + os.environ["PATH"]
        else:
            launcher = bin_dir / backend
            launcher.write_text(f'#!/bin/sh\nexec {shlex.quote(sys.executable)} {shlex.quote(str(compiler))} "$@"\n')
            launcher.chmod(0o755)
            command = ["/bin/bash", str(project / "build.sh")]
            # Isolate compiler discovery from TeX installed on the host.
            for name in ["dirname", "mkdir", "mktemp", "rm", "cp"]:
                executable = shutil.which(name, path="/usr/bin:/bin")
                if executable is None:
                    raise RuntimeError(f"Missing system utility: {name}")
                (bin_dir / name).symlink_to(executable)
            path = str(bin_dir)
        env = dict(os.environ, PATH=path)
        env.pop("FAIL_SOURCE", None)
        env.pop("MISSING_SOURCE", None)
        if fail:
            env["FAIL_SOURCE"] = fail
        if missing:
            env["MISSING_SOURCE"] = missing
        completed = subprocess.run(command, env=env, capture_output=True, text=True, timeout=30)
        self.assertEqual(list((project / "tmp").glob("build.*")), [], completed.stderr)
        self.assertFalse(list(project.glob("*.aux")))
        self.assertFalse(list(project.glob("*.pdf")))
        return completed, published

    @property
    def backends(self):
        return ["xelatex"] if os.name == "nt" else ["latexmk", "xelatex", "tectonic"]

    def test_second_chapter_failure_preserves_both_published_chapters(self):
        for backend in self.backends:
            with self.subTest(backend=backend):
                completed, published = self.build(backend, fail="chapter02")
                self.assertNotEqual(completed.returncode, 0)
                for path in published.iterdir():
                    self.assertEqual(path.read_bytes(), b"previous " + path.name.encode())

    def test_missing_compiler_output_does_not_publish_a_stale_pdf(self):
        for backend in self.backends:
            with self.subTest(backend=backend):
                completed, published = self.build(backend, missing="chapter02")
                self.assertNotEqual(completed.returncode, 0)
                for path in published.iterdir():
                    self.assertEqual(path.read_bytes(), b"previous " + path.name.encode())

    def test_success_publishes_both_chapters(self):
        for backend in self.backends:
            with self.subTest(backend=backend):
                completed, published = self.build(backend)
                self.assertEqual(completed.returncode, 0, completed.stdout + completed.stderr)
                self.assertEqual((published / "chapter-01-cn.pdf").read_bytes(), b"%PDF-1.5 new main")
                self.assertEqual((published / "chapter-02-cn.pdf").read_bytes(), b"%PDF-1.5 new chapter02")


if __name__ == "__main__":
    unittest.main()
