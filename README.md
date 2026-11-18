# ZERO_FAITH

## Canadian IMVE keyword review kit

**[Download the offline ZIP](https://raw.githubusercontent.com/jeyapalc/ZERO_FAITH/imve-review/downloads/imve-review.zip)** or open the [review guide](docs/imve-review/README.md). The ZIP includes one masterlist, six category sublists, a PowerShell scanner, [a prompt for your local AI](docs/imve-review/LOCAL-AI.md), and public research notes.

| Find in authorized records | Plain text | Cited TSV |
| --- | --- | --- |
| Everything | [Masterlist](lists/imve-review/masterlist.txt) | [Masterlist](lists/imve-review/masterlist.tsv) |
| Groups, networks and names | [TXT](lists/imve-review/categories/groups-and-aliases.txt) | [TSV](lists/imve-review/categories/groups-and-aliases.tsv) |
| Incidents and historical figures | [TXT](lists/imve-review/categories/incidents-and-figures.txt) | [TSV](lists/imve-review/categories/incidents-and-figures.tsv) |
| Narratives, slogans and references | [TXT](lists/imve-review/categories/narratives-and-slogans.txt) | [TSV](lists/imve-review/categories/narratives-and-slogans.tsv) |
| Numbers, letters and symbols | [TXT](lists/imve-review/categories/codes-and-symbols.txt) | [TSV](lists/imve-review/categories/codes-and-symbols.tsv) |
| Conduct and artifact context | [TXT](lists/imve-review/categories/conduct-and-context.txt) | [TSV](lists/imve-review/categories/conduct-and-context.tsv) |
| Official terminology | [TXT](lists/imve-review/categories/official-terminology.txt) | [TSV](lists/imve-review/categories/official-terminology.tsv) |

Every result points the reviewer back to the original record. Use the existing [Canadian listed entity registry](CANADA_LTE_CATALOG.md) for wider national security lookups across categories.

## Masterlist and user manual

Start with the [cited masterlist](lists/masterlist.tsv), [one-term-per-line list](lists/masterlist.txt), and [Excel / PowerShell manual](manual/README.md). Each project has one masterlist across source languages. Canadian relevance, evidence, and context govern inclusion; this is not a translation exercise. Existing project translations remain labelled as such, not evidence of Canadian usage. The broader Canadian entity registry remains separate because not every listed entity is IMVE.


**Sourced moderation review vocabulary for ideologically motivated violent extremism (IMVE), with explicit Canadian coverage.**

IMVE follows Canadian policy terminology: xenophobic, anti-authority, gender-driven, and other grievance-driven violence. ZERO_FAITH is a project name, not a claim that faith is extremist. Religiously motivated violent extremism (RMVE) and politically motivated violent extremism (PMVE) are separate Canadian categories; they are not interchangeable with IMVE.

English/German contextual vocabulary, Canadian network references, and general observation prompts are accompanied by a separate Canadian Listed Terrorist Entities (LTE) registry in English and French. Inclusion never establishes a speaker's violent intent or membership.

| File | Purpose |
| --- | --- |
| [CATALOG.md](CATALOG.md) | Readable terms and observation prompts |
| [lists/terms_excel.tsv](lists/terms_excel.tsv) | Excel import: term, enabled switch, tier, category, sources |
| [lists/terms_or.txt](lists/terms_or.txt) | Quoted Boolean OR vocabulary |
| [lists/terms_pipe.txt](lists/terms_pipe.txt) | Pipe-separated readable vocabulary, not executable regex |
| `data/terms.json`, `data/indicators.json` | Canonical records |
| `data/canada/lte_entities.json` | Official EN/FR LTE names, aliases, dates, URLs |
| [docs/CANADA.md](docs/CANADA.md) | Canadian scope and register reconciliation |
| [docs/EXCEL.md](docs/EXCEL.md) | Excel import and false-positive limits |
| [docs/AUDIT.md](docs/AUDIT.md) | Audit findings and remaining gaps |

No ordinary religion, ethnicity, nationality, identity, peaceful advocacy, or philosophy is classified as violent by itself. Research labels are attributed to sources and separate from legal designation. The shared Canadian LTE registry spans categories; it does not classify every entity as IMVE.

Python 3.10+, standard library only:

```sh
python zero_faith.py --include-contextual "text to review"
python tools/build.py
python -m unittest discover -s tests -v
```

All retrieval is contextual and requires opt-in. General research vocabulary is disabled unless `--include-research` is also supplied. A hit is only a literal mention. No intent inference, behavioral assessment, urgency classification, risk scoring, or enforcement is performed. A negative match does not establish safety.

Sources include Canadian agencies, ISD, Canadian Anti-Hate Network, ADL, and German research. Commentary is dated and attributed. German variants are project translations or shared names, not verified native extremist usage. Official Canadian entity names are supplied in English/French. Independent expert review remains outstanding.

Code: MIT. Original annotations: CC0-1.0 to the extent contributors hold the rights. External source rights remain applicable. See CONTRIBUTING.md and license files.

## Canadian audit and spreadsheet exports

See [Canadian coverage](docs/CANADA.md), [Canadian LTE catalog](CANADA_LTE_CATALOG.md), [audit findings](docs/AUDIT.md), and [Excel usage](docs/EXCEL.md). Read [plain-text terms](lists/terms_readable.txt), import [Excel TSV](lists/terms_excel.tsv), or use [Boolean OR](lists/terms_or.txt) / [pipe-separated](lists/terms_pipe.txt) exports. Context is required for every flag.
