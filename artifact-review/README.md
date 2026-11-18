# URL and search records

Run `Find-ArtifactMatch.ps1` from the extracted kit. In a Git checkout the script is under `manual/`. Use a UTF-8 CSV or TSV with a record ID column and the original URL or submitted query field. Keep the export and saved results in the case workspace.

| Match | Indicator template | Value |
| --- | --- | --- |
| URL path | [indicator-template.tsv](indicator-template.tsv) | Host and path, optionally including the full query string |
| Website | [domains/site-indicators.tsv](domains/site-indicators.tsv) | Exact hostname |
| Search query | [indicator-template.tsv](indicator-template.tsv) | Exact submitted query, ignoring case and outer spaces |

Add a unique local ID to each row. Enter `url`, `domain` or `search_query` as the kind. For example, a `url` rule can contain `catalog.example/items/notebook`. Use [website matching](domains/README.md) for a host-only search. The script reads the exported values offline.

```powershell
.\Find-ArtifactMatch.ps1 -IndicatorPath '.\artifact-review\indicator-template.tsv' `
  -ArtifactPath 'C:\CaseWork\visits.csv' -ArtifactKind url `
  -ValueColumn 'url' -RecordIdColumn 'record_id' -TimestampColumn 'timestamp' `
  -OutputPath 'C:\CaseWork\url-hits.csv'
```

Specify the actual names of your export columns. The output gives the matched ID, export record number, source record ID, timestamp, field and value. `-TimestampColumn` is optional. Use the [blank review log](context-review-template.tsv) if needed.

URL rules compare the parsed host and case-sensitive path. Scheme, default port and fragment are ignored. A query string in a rule must match in full and in order. A path-only rule accepts any query string on that path.
