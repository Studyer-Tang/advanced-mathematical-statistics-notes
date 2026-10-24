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
TARGETS = {"main": "chapter-01-cn", **{f"chapter{i:02}": f"chapter-{i:02}-cn" for i in range(2, 6)}, "complete": "complete-cn"}
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
        for source in TARGETS:
            (project / (source + ".tex")).touch()
        published = project / "output" / "pdf"
        published.mkdir(parents=True)
        for name in [target + ".pdf" for target in TARGETS.values()]:
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

    def test_last_document_failure_preserves_complete_edition(self):
        for backend in self.backends:
            with self.subTest(backend=backend):
                completed, published = self.build(backend, fail="complete")
                self.assertNotEqual(completed.returncode, 0)
                for path in published.iterdir():
                    self.assertEqual(path.read_bytes(), b"previous " + path.name.encode())

    def test_missing_compiler_output_does_not_publish_a_stale_pdf(self):
        for backend in self.backends:
            with self.subTest(backend=backend):
                completed, published = self.build(backend, missing="complete")
                self.assertNotEqual(completed.returncode, 0)
                for path in published.iterdir():
                    self.assertEqual(path.read_bytes(), b"previous " + path.name.encode())

    def test_success_publishes_complete_edition(self):
        for backend in self.backends:
            with self.subTest(backend=backend):
                completed, published = self.build(backend)
                self.assertEqual(completed.returncode, 0, completed.stdout + completed.stderr)
                self.assertEqual(len(list(published.glob("*.pdf"))), len(TARGETS))
                for source, target in TARGETS.items():
                    self.assertEqual((published / (target + ".pdf")).read_bytes(), b"%PDF-1.5 new " + source.encode())



if __name__ == "__main__":
    unittest.main()
