# Canadian IMVE keyword review

Download and extract the [offline ZIP](https://raw.githubusercontent.com/jeyapalc/ZERO_FAITH/imve-review/downloads/imve-review.zip) in an approved work location. The kit searches exported text locally and produces a CSV of candidate passages for an examiner. It requires no account or network connection after download. Use [LOCAL-AI.md](LOCAL-AI.md) to have an approved local assistant walk you through the PowerShell command.

## Choose a list

| List in the ZIP | Use it for |
| --- | --- |
| `masterlist.txt` or `masterlist.tsv` | Search across the six categories |
| `categories/groups-and-aliases` | Networks, chapters, group names and aliases |
| `categories/incidents-and-figures` | Canadian cases, historical events, named offenders and documented references to them |
| `categories/narratives-and-slogans` | Repeated phrases, ideological narratives, slogans and cultural references |
| `categories/codes-and-symbols` | Number codes, initials, mixed codes, searchable glyphs and symbol names |
| `categories/conduct-and-context` | Source passages about threats, coercion, reporting and related artifacts |
| `categories/official-terminology` | Canadian IMVE terminology and sourced terminology used in the original projects |

Each list has a `.txt` and a `.tsv`. The TXT contains all its terms, one per line, for copying into the Find dialog in your tool. The TSV includes the category, term type, review note and sources. In Excel use **Data > From Text/CSV**, select UTF-8 and Tab, and set columns to **Text** before loading. That preserves entries such as `14/88` and `18`. Filter by `category`, `term_kind`, or `enabled`. Use the six sublists to focus review on one question at a time.

Select a list based on the authorized question and the material. The kit includes Canadian evidence and cross-border references from the three original projects and research pilot. The Canadian scope follows CSIS coverage of xenophobic, anti-authority, gender identity-driven and other grievance-driven violence, including its discussion of nihilistic violent extremism. Public references are searchable in their attested languages. Source annotations identify editorial translations carried forward from the original projects. A group name in the kit can be a research reference, a public allegation or a listed entity. Check the cited material and the current register for its status. [CSIS 2024 report](https://www.canada.ca/en/security-intelligence-service/corporate/publications/csis-public-report-2024/intelligence-operations.html) · [CSIS 2025 report](https://www.canada.ca/en/security-intelligence-service/corporate/publications/csis-public-report-2025/operations-and-analysis.html) · [Public Safety Canada entity registry](https://www.publicsafety.gc.ca/cnt/ntnl-scrt/cntr-trrrsm/lstd-ntts/crrnt-lstd-ntts-en.aspx)

## Scan an export in PowerShell

Keep the original acquisition, working export and results in the approved evidence workspace, outside any Git checkout. From the extracted kit folder, use absolute case paths and give each output a fresh filename. The examples use fictional paths.

```powershell
.\Find-WordList.ps1 -WordListPath '.\masterlist.tsv' -DocumentPath 'C:\CaseWork\export.txt' -OutputPath 'C:\CaseWork\imve-matches.csv' -WholeWord
```

The first pass scans rows marked `TRUE`. For the complete masterlist, add `-AllTerms`. For a focused second pass with numbers, letters and symbols, use the category list and include `-AllTerms`, since those entries are opt-in.

```powershell
.\Find-WordList.ps1 -WordListPath '.\categories\codes-and-symbols.tsv' -DocumentPath 'C:\CaseWork\export.txt' -OutputPath 'C:\CaseWork\imve-codes.csv' -WholeWord -AllTerms
```

PowerShell can read UTF-8 TXT, CSV, TSV, LOG and Markdown. For documents, screenshots, chat images, audio or forensic containers, first export text, captions, OCR or transcripts with an approved tool. Examine the original image or record alongside any text hit. Symbol names can match annotations. Literal glyphs such as `ᛟ`, `卍` and `卐` can match when those characters occur in exported text. Runes and swastika-like shapes also have historical, cultural and religious uses. Preserve the source image, surrounding language and context in the case workspace. [ADL Visual Database](https://www.adl.org/resources/hate-symbols/search) · [Public Order Emergency Commission report, Vol. 3](https://publicorderemergencycommission.ca/files/documents/Final-Report/Vol-3-Report-of-the-Public-Inquiry-into-the-2022-Public-Order-Emergency.pdf)

The scanner records the first literal occurrence of each term on each export line. `-WholeWord` reduces accidental matches inside other words or numbers. It can miss glyphs embedded in a longer token. A focused Ctrl+F pass can find those strings. Search variants separately when punctuation, accents, spacing, OCR or line wrapping changes the text. The CSV gives export line and column. Use the original artifact ID for the evidence record. CSV matching includes every field on the line, so check which field contains the hit.

## Examine and document

1. **Find.** Record the list version, input export and options. Open the CSV through Excel's text import or an approved local viewer.
2. **Examine.** Open the original artifact. Check who authored, received, quoted or reposted the passage. Read the surrounding exchange and validate timestamps and attribution. Separate victim disclosures, reporting and incidental references from claims about someone's conduct.
3. **Corroborate.** Look for independently supported evidence of a threat or harmful conduct. Record contrary evidence, duplicate records and remaining uncertainty. Use the [blank review log](review-log-template.tsv) and the existing evidence triage guide included in the ZIP.
4. **Record the human decision.** Use your office’s case procedures. Typical dispositions are **no threat supported by the examined artifact**, **insufficient context**, **refer for further review**, or **urgent escalation**. State the evidence and grounds for the decision. A zero-hit scan leaves any unsearched content and potential threats unresolved. Follow your office’s emergency route for imminent danger. [RCMP National Security Information Network](https://rcmp.ca/en/federal-policing/national-security/national-security-information-network)

## Sources and coverage

The ZIP includes the NVE research pilot, source review, literature blind spots and manifesto language audit under `research/`. The GitHub branch records list provenance and lets you rebuild the exports. The first-pass selection is editorial and has been exercised with synthetic test records. Operational recall and false-positive rates remain unmeasured.
