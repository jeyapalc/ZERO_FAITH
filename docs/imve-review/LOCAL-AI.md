# Prompt for a local AI assistant

Open this file in a text editor and copy the prompt below into an approved local assistant. Give it paths using only the specificity your office permits. A case document or its contents are unnecessary for building the command.

## Copy this prompt

> Help me generate Windows PowerShell commands for a local, human-reviewed Canadian IMVE keyword search. Walk me through the setup one question at a time and wait for each answer. Use the answers to construct a ready-to-copy command. I will run the commands myself.
>
> 1. Ask me for the full local folder path where I extracted the IMVE ZIP. If I used the GitHub checkout, ask for the repository root instead. For the ZIP the scanner is `Find-WordList.ps1`, the masterlist is `masterlist.tsv`, and the sublists are under `categories`. For the checkout the scanner is `manual\Find-WordList.ps1`, the masterlist is `lists\imve-review\masterlist.tsv`, and sublists are under `lists\imve-review\categories`. Use the new cited masterlist path for the search.
> 2. Ask for the absolute path to the exported document or documents. Expected formats are UTF-8 TXT, CSV, TSV, LOG or MD. For PDF, Word, images, audio or forensic containers, ask me to export the text through my approved office tool and come back with the export path. Ask for paths only. Keep the evidence and outputs local.
> If I am trying to establish what someone searched for, viewed, ordered or paid for, direct me first to the relevant browser, app or transaction records described in the guide. Ask whether I have those artifact exports. Report wording from the public list may be useful when reviewing incident reports and discussion. A keyword hit alone supplies no evidence of what action occurred.
> 3. Ask which pass I want. Offer **first-pass masterlist** using the default enabled entries, **complete masterlist** using `-AllTerms`, and **one category** using that category's TSV and `-AllTerms`. If I pick a category, ask me which one. The filenames are `groups-and-aliases.tsv`, `incidents-and-figures.tsv`, `narratives-and-slogans.tsv`, `codes-and-symbols.tsv`, `conduct-and-context.tsv` and `official-terminology.tsv`.
> 4. Ask for a new output CSV path inside my approved case workspace. Give me `Test-Path -LiteralPath '<path>' -PathType Leaf` checks for the scanner, TSV and each document. Give me a check that the output parent folder exists and that the chosen CSV path is unused. If any check fails, ask me to correct the path before proceeding.
> 5. Print one ready-to-copy command using the call operator `&`, absolute paths and these exact parameters, `-WordListPath`, `-DocumentPath`, `-OutputPath` and `-WholeWord`. Add `-AllTerms` if I chose a complete or category pass. Put each path in single quotes and double any apostrophe inside it. For multiple documents pass an array such as `@('C:\CaseWork\one.txt', 'C:\CaseWork\two.tsv')`. Use the existing scanner. If the office blocks PowerShell scripts, point me to the manual TXT and Excel options in the guide.
> 6. Tell me how to open the result CSV as text in Excel, locate a matched export line and validate it against the original record. Leave decisions to the human reviewer. Keep the number of keyword hits out of any threat rating.

Example shape for one fictional document and a category pass

```powershell
& 'C:\Tools\IMVE\Find-WordList.ps1' -WordListPath 'C:\Tools\IMVE\categories\codes-and-symbols.tsv' -DocumentPath 'C:\CaseWork\export.txt' -OutputPath 'C:\CaseWork\imve-codes.csv' -WholeWord -AllTerms
```
