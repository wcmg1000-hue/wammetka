# Local compile-time defines (gitignored). Copy from .env:
# SUPABASE_URL=https://wwhyypadkjjbgkmlbpss.supabase.co
# SUPABASE_ANON_KEY=...
# SEED_PASSWORD=...
# Never include SUPABASE_SERVICE_ROLE_KEY.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $root) { $root = Get-Location }
$envFile = Join-Path $root '.env'
$outFile = Join-Path $root 'dart_defines.local.json'
if (-not (Test-Path $envFile)) {
  Write-Error '.env missing'
}
$map = @{}
Get-Content $envFile | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
  $k, $v = $_.Split('=', 2)
  $k = $k.Trim()
  $v = $v.Trim().Trim('"')
  if ($k -in @('SUPABASE_URL','SUPABASE_ANON_KEY','SUPABASE_PUBLISHABLE_KEY','SEED_PASSWORD')) {
    $map[$k] = $v
  }
}
if (-not $map.ContainsKey('SUPABASE_ANON_KEY') -or $map['SUPABASE_ANON_KEY'] -match 'tu_anon_key|^sb_publishable_xxx$|^$') {
  Write-Error 'SUPABASE_ANON_KEY missing in .env'
}
if (-not $map.ContainsKey('SEED_PASSWORD') -or $map['SEED_PASSWORD'] -eq 'contraseña_de_seed_solo_staging') {
  Write-Error 'SEED_PASSWORD missing in .env'
}
if (-not $map.ContainsKey('SUPABASE_URL')) {
  $map['SUPABASE_URL'] = 'https://wwhyypadkjjbgkmlbpss.supabase.co'
}
$jsonMap = @{
  SUPABASE_URL = $map['SUPABASE_URL']
  SUPABASE_ANON_KEY = $map['SUPABASE_ANON_KEY']
  SEED_PASSWORD = $map['SEED_PASSWORD']
}
if ($map.ContainsKey('SUPABASE_PUBLISHABLE_KEY') -and $map['SUPABASE_PUBLISHABLE_KEY'] -notmatch 'sb_publishable_xxx|^$') {
  $jsonMap['SUPABASE_PUBLISHABLE_KEY'] = $map['SUPABASE_PUBLISHABLE_KEY']
}
$json = $jsonMap | ConvertTo-Json -Compress
Set-Content -Path $outFile -Value $json -Encoding utf8
Write-Output 'dart_defines.local.json written (keys not printed)'
