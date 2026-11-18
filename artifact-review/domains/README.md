# Website matching for local records

Add approved hostnames to a case workspace copy of `site-indicators.tsv`. Each row needs a local ID, `domain` as the kind, and the exact hostname. The template is blank. The scanner reads exported URL fields and compares their parsed hostname offline. Enter a separate row for each known subdomain. A hostname quoted in a query string or appearing in a lookalike domain is a separate value and produces no match for the original hostname.

Fictional example

```tsv
indicator_id	kind	value
SITE-01	domain	catalog.example
```

Run from the kit root. Replace the export and column names with your own.

```powershell
.\Find-ArtifactMatch.ps1 -IndicatorPath '.\artifact-review\domains\site-indicators.tsv' `
  -ArtifactPath 'C:\CaseWork\visits.csv' -ArtifactKind domain `
  -ValueColumn 'url' -RecordIdColumn 'record_id' -TimestampColumn 'timestamp' `
  -OutputPath 'C:\CaseWork\website-hits.csv'
```

The script reads the URL as text and makes no network requests. An exact host match returns the original URL field, record ID and optional timestamp. For an approved indicator that identifies one page on a shared domain, use the kit's `url` mode so that other pages on the same host stay out of that search.

The Canadian public register covers listed entities. Tech Against Terrorism issues alerts about specific URLs for participating platforms and vets access. GIFCT shares hashes of specific content with members. Use hostname or URL indicators already authorized for your office or case. [Public Safety Canada entity register](https://www.publicsafety.gc.ca/cnt/ntnl-scrt/cntr-trrrsm/lstd-ntts/index-en.aspx) · [TCAP access and alerts](https://www.terrorismanalytics.org/resources/faq) · [GIFCT hash-sharing database](https://gifct.org/hsdb/)

The FBI Threat Screening Center describes an identity watchlist. The FBI's public terrorism pages list wanted individuals, and the U.S. National Counterterrorism Center public guide profiles terrorist groups. Searches of public CIA and FBI sources did not identify a downloadable IMVE website blocklist for this use. [FBI Threat Screening Center](https://www.fbi.gov/investigate/terrorism/tsc) · [FBI public terrorism list](https://www.fbi.gov/wanted/terrorism) · [NCTC public guide](https://archive.dni.gov/nctc/)
