# Client-only dart-defines for APK. Never include service_role or SEED_PASSWORD.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $root) { $root = Get-Location }
$envFile = Join-Path $root '.env'
$outFile = Join-Path $root 'dart_defines.apk.json'
if (-not (Test-Path $envFile)) {
  Write-Error '.env missing'
}
$map = @{}
Get-Content $envFile | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
  $k, $v = $_.Split('=', 2)
  $k = $k.Trim()
  $v = $v.Trim().Trim('"')
  if ($k -in @('SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_PUBLISHABLE_KEY')) {
    $map[$k] = $v
  }
}
if (-not $map.ContainsKey('SUPABASE_ANON_KEY') -or $map['SUPABASE_ANON_KEY'] -match 'tu_anon_key|^sb_publishable_xxx$|^$') {
  Write-Error 'SUPABASE_ANON_KEY missing in .env'
}
if (-not $map.ContainsKey('SUPABASE_URL')) {
  $map['SUPABASE_URL'] = 'https://wwhyypadkjjbgkmlbpss.supabase.co'
}
$jsonMap = @{
  SUPABASE_URL      = $map['SUPABASE_URL']
  SUPABASE_ANON_KEY = $map['SUPABASE_ANON_KEY']
}
if ($map.ContainsKey('SUPABASE_PUBLISHABLE_KEY') -and $map['SUPABASE_PUBLISHABLE_KEY'] -notmatch 'sb_publishable_xxx|^$') {
  $jsonMap['SUPABASE_PUBLISHABLE_KEY'] = $map['SUPABASE_PUBLISHABLE_KEY']
}
$json = $jsonMap | ConvertTo-Json -Compress
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outFile, $json, $utf8)
Write-Output 'dart_defines.apk.json written (client keys only, not printed)'
