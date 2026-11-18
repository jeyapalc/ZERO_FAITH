[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$IndicatorPath,
    [Parameter(Mandatory=$true)][string]$ArtifactPath,
    [Parameter(Mandatory=$true)][ValidateSet('url', 'domain', 'search_query')][string]$ArtifactKind,
    [Parameter(Mandatory=$true)][string]$ValueColumn,
    [Parameter(Mandatory=$true)][string]$RecordIdColumn,
    [string]$TimestampColumn,
    [Parameter(Mandatory=$true)][string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$listFile = (Resolve-Path -LiteralPath $IndicatorPath).Path
$artifactFile = (Resolve-Path -LiteralPath $ArtifactPath).Path
$outputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
if (Test-Path -LiteralPath $outputFile) { throw 'Choose a new output filename.' }
if ([IO.Path]::GetExtension($outputFile) -ne '.csv') { throw 'Use a .csv output path.' }
if (-not (Test-Path -LiteralPath (Split-Path -Parent $outputFile) -PathType Container)) {
    throw 'The output folder must exist.'
}

function Read-Url([string]$Text) {
    $candidate = $Text.Trim()
    if ($candidate -match '[\x00-\x20\\]') { return }
    if ($candidate -notmatch '^[a-z][a-z0-9+.-]*://') {
        if ($candidate -notmatch '^[^/:?#]+\.[^/:?#]+(?::[0-9]+)?(?:[/?#]|$)') { return }
        $candidate = 'https://' + $candidate
    }

    $uri = $null
    if (-not [Uri]::TryCreate($candidate, [UriKind]::Absolute, [ref]$uri)) { return }
    if ($uri.Scheme -notin @('http', 'https') -or -not $uri.Host -or $uri.UserInfo) { return }
    $authority = $uri.IdnHost.ToLowerInvariant()
    if (-not $uri.IsDefaultPort) { $authority += ':' + $uri.Port }
    [pscustomobject]@{
        Host = $uri.IdnHost.TrimEnd('.').ToLowerInvariant()
        IsDns = $uri.HostNameType -eq [UriHostNameType]::Dns
        HostPath = $authority + $uri.AbsolutePath
        Query = $uri.Query
        Fragment = $uri.Fragment
    }
}

function Protect-CsvText([string]$Value) {
    if ($Value -match '^[\s]*[=+@-]' -or $Value -match '^[\t\r\n]') { return "'" + $Value }
    return $Value
}

$rules = [Collections.Generic.Dictionary[string,Collections.Generic.List[string]]]::new([StringComparer]::Ordinal)
$indicatorIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($row in (Import-Csv -LiteralPath $listFile -Delimiter "`t" -Encoding UTF8)) {
    if (-not $row.indicator_id -or -not $row.value -or $row.kind -notin @('url', 'domain', 'search_query')) {
        throw 'Each private list row needs indicator_id, kind (url, domain or search_query), and value.'
    }
    $id = $row.indicator_id.Trim()
    $value = $row.value.Trim()
    if (-not $value -or -not $id -or -not $indicatorIds.Add($id)) {
        throw 'Private list IDs must be unique, and every row must have a nonblank ID and value.'
    }
    if ($row.kind -ne $ArtifactKind) { continue }
    if ($ArtifactKind -eq 'url') {
        $url = Read-Url $value
        if (-not $url -or $url.Fragment) { throw "Invalid URL indicator: $id. Use a hostname and path without a fragment." }
        $key = $url.HostPath + $url.Query
    } elseif ($ArtifactKind -eq 'domain') {
        $url = Read-Url $value
        if ($value -match '[:/?#@\\\s]' -or -not $url.IsDns -or $url.Host -notmatch '\.') {
            throw "Invalid domain indicator: $id. Enter a hostname only."
        }
        $key = $url.Host
    } else {
        $key = $value.ToUpperInvariant()
    }
    if (-not $rules.ContainsKey($key)) { $rules.Add($key, [Collections.Generic.List[string]]::new()) }
    $rules[$key].Add($id)
}
if (-not $rules.Count) { throw "Add a case-specific $ArtifactKind indicator before running this pass." }

$results = [Collections.Generic.List[object]]::new()
$scanned = 0
$unparsed = 0
$matchedRecords = 0
$columns = @($ValueColumn, $RecordIdColumn)
if ($TimestampColumn) { $columns += $TimestampColumn }
$delimiter = switch ([IO.Path]::GetExtension($artifactFile)) {
    '.csv' { ',' }
    '.tsv' { "`t" }
    default { throw 'Export the relevant artifact type as UTF-8 CSV or TSV.' }
}

Import-Csv -LiteralPath $artifactFile -Delimiter $delimiter -Encoding UTF8 | ForEach-Object {
    $record = $_
    if ($scanned -eq 0) {
        foreach ($column in $columns) {
            if ($null -eq $record.PSObject.Properties[$column]) { throw "Missing export column: $column" }
        }
    }
    $scanned++
    $value = [string]$record.$ValueColumn
    $keys = @()
    if ($ArtifactKind -in @('url', 'domain')) {
        $url = Read-Url $value
        if ($url) {
            if ($ArtifactKind -eq 'domain') {
                $keys += $url.Host
            } else {
                $keys += $url.HostPath
                if ($url.Query) { $keys += $url.HostPath + $url.Query }
            }
        }
    } elseif ($value.Trim()) {
        $keys += $value.Trim().ToUpperInvariant()
    }
    if (-not $keys.Count) { $unparsed++ }

    $hasMatch = $false
    foreach ($key in $keys) {
        if (-not $rules.ContainsKey($key)) { continue }
        $hasMatch = $true
        foreach ($id in $rules[$key]) {
            $results.Add([pscustomobject][ordered]@{
                indicator_id = Protect-CsvText $id
                export_record_number = $scanned
                artifact_id = Protect-CsvText $record.$RecordIdColumn
                timestamp = Protect-CsvText $(if ($TimestampColumn) { $record.$TimestampColumn })
                artifact_kind = $ArtifactKind
                matched_field = Protect-CsvText $ValueColumn
                observed_value = Protect-CsvText $value
            })
        }
    }
    if ($hasMatch) { $matchedRecords++ }
}
if (-not $scanned) { throw 'No records in the artifact export.' }

$csv = if ($results.Count) { @($results | ConvertTo-Csv -NoTypeInformation) } else {
    @('"indicator_id","export_record_number","artifact_id","timestamp","artifact_kind","matched_field","observed_value"')
}
$stream = [IO.File]::Open($outputFile, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
try {
    $writer = [IO.StreamWriter]::new($stream, [Text.UTF8Encoding]::new($true))
    try {
        foreach ($line in $csv) { $writer.WriteLine($line) }
    } finally {
        $writer.Dispose()
    }
} finally {
    $stream.Dispose()
}
Write-Host "Checked $scanned records. Matched $matchedRecords records ($($results.Count) indicator hits). Blank or unparseable selected fields: $unparsed."
