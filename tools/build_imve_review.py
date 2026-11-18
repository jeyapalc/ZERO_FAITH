"""Build the portable IMVE keyword review kit from cited public inputs."""

import csv
from pathlib import Path
from zipfile import ZipFile, ZipInfo


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data/imve-review"
LISTS = ROOT / "lists/imve-review"
DOCS = ROOT / "docs/imve-review"
ZIP = ROOT / "downloads/imve-review.zip"

GROUPS = "groups-and-aliases"
INCIDENTS = "incidents-and-figures"
NARRATIVES = "narratives-and-slogans"
CODES = "codes-and-symbols"
CONDUCT = "conduct-and-context"
POLICY = "official-terminology"
CATEGORIES = (GROUPS, INCIDENTS, NARRATIVES, CODES, CONDUCT, POLICY)

FIELDS = (
    "term", "enabled", "category", "term_kind", "language", "entry_id",
    "context_note", "source_urls", "source_repository", "source_file",
    "source_entries", "source_categories", "evidence_basis",
)
INPUTS = (
    ("CA", "ZERO_FAITH", DATA / "canada.tsv"),
    ("PILOT", "ZERO_FAITH", DATA / "NVE-RESEARCH-PILOT.tsv"),
    ("FAITH", "ZERO_FAITH", ROOT / "lists/masterlist.tsv"),
    ("NIHL", "ZERO_NIHL", DATA / "zero-nihl.tsv"),
    ("NAZ", "ZERO_NAZ", DATA / "zero-naz.tsv"),
)


def read_rows(path):
    with path.open(encoding="utf-8-sig", newline="") as file:
        return list(csv.DictReader(file, delimiter="\t"))


def term_kind(term, source_category):
    if term in {"ᛋᛋ", "ᛟ", "卍", "卐"}:
        return "glyph"
    if source_category == "numeric_code" or any(ch.isdigit() for ch in term):
        if all(ch.isdigit() or ch in "/-:,. " for ch in term):
            return "number"
        if " " not in term and len(term) <= 8:
            return "mixed_code"
    if " " not in term and term.isupper() and len(term) <= 8:
        return "letter_code"
    if source_category == "visual_symbol":
        return "symbol_name"
    return "word_or_phrase"


def category(group, row, kind):
    origin = row.get("category", "")
    term = row["term"]
    entry = row["entry_id"]
    if group == "CA":
        if origin not in CATEGORIES:
            raise ValueError(f"Unrecognized Canadian category for {entry}: {origin}")
        return origin
    if kind in {"number", "mixed_code", "letter_code", "glyph", "symbol_name"}:
        return CODES
    if group == "PILOT":
        if entry == "nve":
            return POLICY
        if entry in {"com", "tcc", "mmc", "o9a-reference", "tob-reference", "terrorgram-reference"}:
            return GROUPS
        if entry in {"columbiners", "saint-culture", "misogyny-context", "racism-context", "blackpill",
                     "replacement-narrative", "white-genocide-narrative", "eurabia-narrative",
                     "cultural-marxism-narrative", "race-war-theme", "blood-libel-reference"}:
            return NARRATIVES
        return INCIDENTS
    if group == "FAITH":
        if term == "James Mason":
            return INCIDENTS
        if origin in {"entity_reference", "scene_term"} or term in {
            "Atalante", "Légion Nationaliste", "Légitime Violence", "Québec Radical",
        }:
            return GROUPS
        if origin == "coded_reference":
            return NARRATIVES
        return POLICY if origin == "research_reference" else CONDUCT
    if group == "NIHL":
        if origin == "network_reference":
            return GROUPS
        if origin == "prior_attacker_reference":
            return INCIDENTS
        if term in {"nihilistic violent extremism", "nihilistischer Gewaltextremismus"}:
            return POLICY
        return CONDUCT
    if origin == "organization":
        return GROUPS
    return INCIDENTS if origin == "person" else NARRATIVES


def merge_rows():
    records = {}
    for group, repository, path in INPUTS:
        for row in read_rows(path):
            term = row["term"]
            entry = row["entry_id"]
            urls = row["source_urls"].split()
            if not term or not entry or not urls or not all(url.startswith("https://") for url in urls):
                raise ValueError(f"Missing literal term, entry ID or citation in {path}: {entry}")
            if any(ch in term for ch in "\t\n\r") or term.lstrip().startswith(("=", "+", "-", "@")):
                raise ValueError(f"Term must be a single literal line safe to import: {entry}")
            if row["enabled"] not in {"TRUE", "FALSE"}:
                raise ValueError(f"Invalid enabled value in {path}: {entry}")
            kind = term_kind(term, row.get("category", ""))
            bucket = category(group, row, kind)
            fields = records.setdefault(term.lower(), {
                "term": term, "enabled": False, "category": bucket, "term_kind": kind,
                "entry_id": f"{group}:{entry}",
                **{field: [] for field in FIELDS[5:] if field != "entry_id"},
                "language": [],
            })
            if bucket == CODES:
                fields["category"] = CODES
                fields["term_kind"] = kind
            fields["enabled"] |= row["enabled"] == "TRUE"
            for field, values in {
                "language": row["language"].split(","),
                "context_note": [row["context_note"]],
                "source_urls": urls,
                "source_repository": [repository],
                "source_file": [path.relative_to(ROOT).as_posix()],
                "source_entries": [f"{group}:{entry}"],
                "source_categories": [row.get("category", "") or "research_pilot"],
                "evidence_basis": [row.get("evidence_basis", "") or "see cited source and context note"],
            }.items():
                for value in values:
                    if value and value not in fields[field]:
                        fields[field].append(value)
    output = []
    for record in sorted(records.values(), key=lambda row: (row["term"].lower(), row["term"])):
        enabled = record["enabled"] and record["category"] != CODES
        record["enabled"] = "TRUE" if enabled else "FALSE"
        for field in FIELDS:
            if isinstance(record[field], list):
                separator = " " if field == "source_urls" else ", " if field == "language" else " | "
                record[field] = separator.join(record[field])
        output.append(record)
    return output


def write_list(directory, name, rows):
    directory.mkdir(parents=True, exist_ok=True)
    table = directory / f"{name}.tsv"
    with table.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, FIELDS, delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)
    plain = directory / f"{name}.txt"
    plain.write_bytes("".join(row["term"] + "\n" for row in rows).encode("utf-8"))
    return (table, plain)


def build():
    rows = merge_rows()
    exports = list(write_list(LISTS, "masterlist", rows))
    for label in CATEGORIES:
        subset = [row for row in rows if row["category"] == label]
        exports.extend(write_list(LISTS / "categories", label, subset))
    kit = {path.relative_to(LISTS).as_posix(): path for path in exports}
    kit.update({
        "README.md": DOCS / "README.md",
        "LOCAL-AI.md": DOCS / "LOCAL-AI.md",
        "Find-WordList.ps1": ROOT / "manual/Find-WordList.ps1",
        "LICENSE": ROOT / "LICENSE",
        "data-LICENSE": ROOT / "data/LICENSE",
        "review-log-template.tsv": DOCS / "review-log-template.tsv",
        "EVIDENCE_TRIAGE.md": ROOT / "manual/EVIDENCE_TRIAGE.md",
        "research/NVE-RESEARCH-PILOT.tsv": DATA / "NVE-RESEARCH-PILOT.tsv",
    })
    kit.update({f"research/{path.name}": path for path in DOCS.glob("NVE-*.md")})
    ZIP.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(ZIP, "w") as archive:
        for name, path in sorted(kit.items()):
            member = ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
            archive.writestr(member, path.read_bytes().replace(b"\r\n", b"\n"))
    print(f"{len(rows)} distinct terms, {sum(row['enabled'] == 'TRUE' for row in rows)} enabled.")
    for label in CATEGORIES:
        print(f"  {label}: {sum(row['category'] == label for row in rows)}")


if __name__ == "__main__":
    build()
