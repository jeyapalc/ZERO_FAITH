"""Check that the portable kit preserves vocabulary and source provenance."""

import sys
import unittest
from pathlib import Path
from zipfile import ZipFile


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from build_imve_review import CATEGORIES, DOCS, INPUTS, LISTS, ROOT, ZIP, read_rows


class ImveKitTests(unittest.TestCase):
    def test_master_contains_every_source_term_and_citation(self):
        rows = read_rows(LISTS / "masterlist.tsv")
        by_term = {row["term"].lower(): row for row in rows}
        self.assertEqual(len(rows), len(by_term))
        source_terms = set()
        for code, _, file in INPUTS:
            for source in read_rows(file):
                term = source["term"].lower()
                source_terms.add(term)
                combined = by_term[term]
                self.assertIn(f"{code}:{source['entry_id']}", combined["source_entries"].split(" | "))
                self.assertLessEqual(set(source["source_urls"].split()), set(combined["source_urls"].split()))
        self.assertEqual(set(by_term), source_terms)
        self.assertEqual(by_term["764"]["enabled"], "FALSE")
        self.assertEqual(by_term["ruby ridge"]["enabled"], "TRUE")
        self.assertEqual(by_term["brenton tarrant"]["category"], "incidents-and-figures")
        self.assertEqual(by_term["hide and stalk"]["category"], "groups-and-aliases")

    def test_categories_partition_the_master_and_plain_text_matches(self):
        master = read_rows(LISTS / "masterlist.tsv")
        for category in CATEGORIES:
            stem = LISTS / "categories" / category
            subset = read_rows(stem.with_suffix(".tsv"))
            self.assertTrue(subset)
            self.assertEqual(subset, [row for row in master if row["category"] == category])
            self.assertEqual(stem.with_suffix(".txt").read_text(encoding="utf-8").splitlines(),
                             [row["term"] for row in subset])
        self.assertEqual((LISTS / "masterlist.txt").read_text(encoding="utf-8").splitlines(),
                         [row["term"] for row in master])
        self.assertLessEqual({row["category"] for row in master}, set(CATEGORIES))

    def test_zip_is_a_standalone_copy_of_the_public_kit(self):
        members = {
            path.relative_to(LISTS).as_posix(): path
            for path in LISTS.rglob("*") if path.is_file()
        }
        members.update({
            "README.md": DOCS / "README.md",
            "LOCAL-AI.md": DOCS / "LOCAL-AI.md",
            "Find-WordList.ps1": ROOT / "manual/Find-WordList.ps1",
            "review-log-template.tsv": DOCS / "review-log-template.tsv",
            "EVIDENCE_TRIAGE.md": ROOT / "manual/EVIDENCE_TRIAGE.md",
            "research/NVE-RESEARCH-PILOT.tsv": ROOT / "data/imve-review/NVE-RESEARCH-PILOT.tsv",
            "LICENSE": ROOT / "LICENSE",
            "data-LICENSE": ROOT / "data/LICENSE",
        })
        for note in DOCS.glob("NVE-*.md"):
            members[f"research/{note.name}"] = note
        with ZipFile(ZIP) as kit:
            self.assertEqual(kit.namelist(), sorted(members))
            self.assertIsNone(kit.testzip())
            for entry in kit.infolist():
                self.assertEqual(entry.create_system, 3)
                self.assertEqual(entry.external_attr >> 16, 0o100644)
            for name, path in members.items():
                self.assertEqual(kit.read(name), path.read_bytes().replace(b"\r\n", b"\n"))


if __name__ == "__main__":
    unittest.main()
