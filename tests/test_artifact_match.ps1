param([Parameter(Mandatory=$true)][string]$KitRoot)

$ErrorActionPreference = 'Stop'
$scanner = Join-Path $KitRoot 'Find-ArtifactMatch.ps1'
$directory = Join-Path ([IO.Path]::GetTempPath()) ('artifact-review-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $directory | Out-Null
$list = Join-Path $directory 'indicators.tsv'
$document = Join-Path $directory 'browser export.csv'

function Assert-Equal($Actual, $Expected, [string]$Message) {
    if ($Actual -cne $Expected) { throw "$Message Expected '$Expected', got '$Actual'." }
}

@(
    "indicator_id`tkind`tvalue"
    "URL-01`turl`tcatalog.example/items/notebook"
    "URL-02`turl`tcatalog.example/item?id=732"
    "QUERY-01`tsearch_query`tblue notebook"
    "SITE-01`tdomain`tcatalog.example"
) | Set-Content -LiteralPath $list -Encoding UTF8
@'
record_id,timestamp,url,title,query
A01,2026-01-01T09:12:00Z,https://catalog.example/items/notebook,Notebook,blue notebook
A02,2026-01-01T09:13:00Z,http://CATALOG.EXAMPLE/items/notebook?ref=news,Notebook,BLUE NOTEBOOK
A03,2026-01-01T09:14:00Z,catalog.example/items/notebook,Notebook,used blue notebook
A04,2026-01-01T09:15:00Z,https://catalog.example.other.example/items/notebook,Notebook,
A05,2026-01-01T09:16:00Z,https://catalog.example/items/notebooks,Notebooks,
A06,2026-01-01T09:17:00Z,https://other.example/search?q=https://catalog.example/items/notebook,Link,
A07,2026-01-01T09:18:00Z,https://catalog.example/item?id=732,Item,
A08,2026-01-01T09:19:00Z,https://catalog.example/item?id=733,Item,
A09,2026-01-01T09:20:00Z,garbled text,Bad export,
A10,2026-01-01T09:21:00Z,https://catalog.example@other.example/items/notebook,Link,
A11,2026-01-01T09:22:00Z,https://other.example/help,https://catalog.example/items/notebook,
A12,2026-01-01T09:23:00Z,https://catalog.example:443/items/notebook#reviews,Notebook,
A13,2026-01-01T09:24:00Z,https://catalog.example/items/Notebook,Notebook,
A14,2026-01-01T09:25:00Z,https://catalog.example/item?id=732&promo=1,Item,
A15,2026-01-01T09:26:00Z,https://www.catalog.example/items/notebook,Notebook,
A16,2026-01-01T09:27:00Z,https://catalog.example./another-page,Page,
'@ | Set-Content -LiteralPath $document -Encoding UTF8

$urlReport = Join-Path $directory 'url.csv'
& $scanner -IndicatorPath $list -ArtifactPath $document -ArtifactKind url -ValueColumn url -RecordIdColumn record_id -TimestampColumn timestamp -OutputPath $urlReport
$hits = @(Import-Csv -LiteralPath $urlReport)
Assert-Equal ($hits.artifact_id -join ',') 'A01,A02,A03,A07,A12' 'URL test found an unexpected set of records.'
Assert-Equal ($hits.indicator_id -join ',') 'URL-01,URL-01,URL-01,URL-02,URL-01' 'URL test linked the wrong rules.'
Assert-Equal $hits[0].timestamp '2026-01-01T09:12:00Z' 'Timestamp was lost.'
Assert-Equal $hits[0].matched_field 'url' 'Matched field was lost.'

$queryReport = Join-Path $directory 'query.csv'
& $scanner -IndicatorPath $list -ArtifactPath $document -ArtifactKind search_query -ValueColumn query -RecordIdColumn record_id -OutputPath $queryReport
$hits = @(Import-Csv -LiteralPath $queryReport)
Assert-Equal ($hits.artifact_id -join ',') 'A01,A02' 'Search-query test must match complete submitted-query field only.'

$domainReport = Join-Path $directory 'domain.csv'
& $scanner -IndicatorPath $list -ArtifactPath $document -ArtifactKind domain -ValueColumn url -RecordIdColumn record_id -OutputPath $domainReport
$hits = @(Import-Csv -LiteralPath $domainReport)
Assert-Equal ($hits.artifact_id -join ',') 'A01,A02,A03,A05,A07,A08,A12,A13,A14,A16' 'Domain test must match only the parsed hostname.'
Assert-Equal (@($hits | Where-Object indicator_id -ne 'SITE-01').Count) 0 'Domain test included an unrelated rule.'

$blocked = $false
try {
    & $scanner -IndicatorPath $list -ArtifactPath $document -ArtifactKind url -ValueColumn url -RecordIdColumn record_id -OutputPath $document
} catch {
    $blocked = $_.Exception.Message -eq 'Choose a new output filename.'
}
Assert-Equal $blocked $true 'The scanner must protect the input file.'
Write-Host 'All artifact tests passed. Fixture counts: 5 URL hits, 2 query hits, and 10 exact hostname hits.'

$safetyExample = Join-Path $directory 'safety-export.txt'
@(
    'Fictional shipping label: Class 3 - Flammable liquids.'
    'Fictional title: Informations relatives au transport.'
    'Fictional workplace record: safety glasses and first aid kit.'
    'Fictional document title: nonstandard transport class 3.'
) | Set-Content -LiteralPath $safetyExample -Encoding UTF8
$wordScanner = Join-Path $KitRoot 'Find-WordList.ps1'
$labelsReport = Join-Path $directory 'hazard-labels.csv'
& $wordScanner -WordListPath (Join-Path $KitRoot 'whmis/hazard-labels.tsv') -DocumentPath $safetyExample -OutputPath $labelsReport -WholeWord
$labels = @(Import-Csv -LiteralPath $labelsReport)
Assert-Equal (($labels.entry_id | Sort-Object) -join ',') 'fds-transport,tdg-liquid' 'Unexpected label hits.'
$ppeReport = Join-Path $directory 'workplace-safety.csv'
& $wordScanner -WordListPath (Join-Path $KitRoot 'whmis/workplace-safety.tsv') -DocumentPath $safetyExample -OutputPath $ppeReport -WholeWord
$ppe = @(Import-Csv -LiteralPath $ppeReport)
Assert-Equal (($ppe.entry_id | Sort-Object) -join ',') 'first-aid-kit,safety-glasses' 'Unexpected PPE and safety equipment hits.'

$contextExample = Join-Path $directory 'context-export.txt'
@(
    'Fictional notes: a kitchen knife was in the inventory.'
    'Fictional first-aid class: tourniquets were discussed.'
    'Fictional reservation: supervised shooting range visit.'
    'Fictional licence record: hunting licence renewal.'
    'Fictional news quote: police responded to a weapons complaint.'
    'Fictional inventory identifier: butterknife.'
    'Fictional record: threatening message quoted a threat to kill.'
    'Fictional dispatch entry: shots fired.'
    'Fictional safety report: blocked emergency exit.'
    'Fictional schedule: range reservation and hunter education.'
    'Fictional course roster: bleeding control and pressure dressing.'
    'Fictional reading list: Uvalde, Vegas shooting and North Hollywood shootout.'
    'Fictional index: Christopher Dorner and Saints Culture.'
    'Fictional research notes: January 6 Capitol attack, Oath Keepers and Diagolon.'
) | Set-Content -LiteralPath $contextExample -Encoding UTF8
$contextList = Join-Path $KitRoot 'context-mentions.tsv'
$contextReport = Join-Path $directory 'context-hits.csv'
& $wordScanner -WordListPath $contextList -DocumentPath $contextExample -OutputPath $contextReport -WholeWord -AllTerms
$contextHits = @(Import-Csv -LiteralPath $contextReport)
$expectedTerms = 'bleeding-control,blocked-emergency-exit,diagolon,dorner,hunter-education,hunting,hunting-licence,jan-six-capitol-attack,knife,north-hollywood-shootout,oath-keepers,police-responded,pressure-dressing,range-reservation,saints-culture,shooting-range,shots-fired,threat-to-kill,threatening-message,tourniquets,uvalde,vegas-shooting,weapons-complaint' -split ','
Assert-Equal (($contextHits.entry_id | Sort-Object) -join ',') (($expectedTerms | Sort-Object) -join ',') 'Unexpected context hits.'
Assert-Equal (@($contextHits | Where-Object line_number -eq 6).Count) 0 'Whole-word mode matched a substring.'
$contextRows = @(Import-Csv -LiteralPath $contextList -Delimiter "`t" -Encoding UTF8)
Assert-Equal (@($contextRows | Where-Object enabled -ne 'FALSE').Count) 0 'Context list must be opt-in.'
Assert-Equal (@($contextRows.term | Sort-Object -Unique).Count) $contextRows.Count 'Context list contains duplicate terms.'
$plain = Get-Content -LiteralPath (Join-Path $KitRoot 'context-mentions.txt') -Encoding UTF8
Assert-Equal ($plain -join "`n") ($contextRows.term -join "`n") 'Plain text list differs from the TSV.'
Write-Host 'Safety and contextual wordlist tests passed.'
