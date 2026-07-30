from hashlib import sha256
from pathlib import Path
import shutil
import subprocess
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "prepare-docs-tree.py"


def tree_digest(root: Path) -> str:
    digest = sha256()
    for path in sorted(item for item in root.rglob("*") if item.is_file()):
        digest.update(path.relative_to(root).as_posix().encode())
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


class GeneratedDocsTreeTests(unittest.TestCase):
    def setUp(self):
        self.relative_output = Path(f".generated-docs-test-{uuid.uuid4().hex}")
        self.output = ROOT / self.relative_output

    def tearDown(self):
        shutil.rmtree(self.output, ignore_errors=True)

    def run_preparer(self):
        subprocess.run(
            ["python3", str(SCRIPT), "--output", str(self.relative_output)],
            cwd=ROOT,
            check=True,
            text=True,
            capture_output=True,
        )

    def test_generated_tree_is_deterministic_and_version_local(self):
        source_readme = (ROOT / "docs" / "README.md").read_text()

        self.run_preparer()
        first_digest = tree_digest(self.output)
        self.run_preparer()

        self.assertEqual(first_digest, tree_digest(self.output))
        self.assertEqual(source_readme, (ROOT / "docs" / "README.md").read_text())
        self.assertTrue((self.output / "repository" / "SECURITY.md").is_file())
        self.assertTrue((self.output / "repository" / "CONTRIBUTING.md").is_file())
        self.assertTrue((self.output / "repository" / "release-channels.json").is_file())

        generated_index = (self.output / "README.md").read_text()
        self.assertIn(
            "](repository/CONTRIBUTING.md)",
            generated_index,
        )
        self.assertNotIn(
            "](../CONTRIBUTING.md)",
            generated_index,
        )

        generated_contributing = (
            self.output / "repository" / "CONTRIBUTING.md"
        ).read_text()
        self.assertIn("](../README.md)", generated_contributing)
        self.assertNotIn("](docs/README.md)", generated_contributing)

        generated_root_readme = (self.output / "repository" / "README.md").read_text()
        self.assertIn("](release-channels.json)", generated_root_readme)
        self.assertNotIn("](.release-channels.json)", generated_root_readme)

        upstream = (self.output / "repository" / "upstream-review.md").read_text()
        self.assertIn("](../compatibility.md)", upstream)

    def test_preparer_rejects_canonical_or_repository_root_output(self):
        for output in [".", "docs"]:
            result = subprocess.run(
                ["python3", str(SCRIPT), "--output", output],
                cwd=ROOT,
                text=True,
                capture_output=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("must", result.stderr)


if __name__ == "__main__":
    unittest.main()
