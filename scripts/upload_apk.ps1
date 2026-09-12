# Upload arm64 APK to Supabase Storage as seed admin (no service_role).
# Secrets from .env only. Does not print keys or tokens.
param(
  [Parameter(Mandatory = $true)][string]$ApkPath,
  [Parameter(Mandatory = $true)][int]$VersionCode,
  [string]$LatestVersion = '0.1.0',
  [string]$Changelog = 'Nueva version de Wammetka',
  [switch]$ForceUpdate
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root '.env'
if (-not (Test-Path $ApkPath)) { throw "APK missing: $ApkPath" }
if (-not (Test-Path $envFile)) { throw '.env missing' }

$map = @{}
Get-Content $envFile | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
  $k, $v = $_.Split('=', 2)
  $map[$k.Trim()] = $v.Trim().Trim('"')
}
$url = $map['SUPABASE_URL']
$anon = $map['SUPABASE_ANON_KEY']
if (-not $anon) { $anon = $map['SUPABASE_PUBLISHABLE_KEY'] }
$pass = $map['SEED_PASSWORD']
if (-not $url -or -not $anon -or -not $pass) { throw 'SUPABASE_URL, anon/publishable or SEED_PASSWORD missing' }

$sha = (Get-FileHash -Algorithm SHA256 -Path $ApkPath).Hash.ToLowerInvariant()
$name = "wammetka-v$LatestVersion+$VersionCode-arm64.apk"
$objectPath = "releases/$name"
$temp = Join-Path $env:TEMP $name
Copy-Item -Force $ApkPath $temp

$authBody = @{ email = 'admin@wammetka.test'; password = $pass } | ConvertTo-Json -Compress
$authFile = Join-Path $env:TEMP 'wam_auth.json'
[System.IO.File]::WriteAllText($authFile, $authBody)
$authOut = Join-Path $env:TEMP 'wam_auth_out.json'
$authCode = curl.exe --http1.1 -sS -o $authOut -w "%{http_code}" `
  -X POST "$url/auth/v1/token?grant_type=password" `
  -H "apikey: $anon" `
  -H "Content-Type: application/json" `
  --data-binary "@$authFile"
if ($authCode.Trim() -ne '200') { throw "Auth HTTP $($authCode.Trim())" }
$authJson = Get-Content $authOut -Raw | ConvertFrom-Json
$token = $authJson.access_token
if (-not $token) { throw 'No access token' }

$dest = "$url/storage/v1/object/apk/$objectPath"
Write-Output "Uploading $name (no secrets printed)"
$upCode = curl.exe --http1.1 -sS -o "$env:TEMP\wam_upload_out.txt" -w "%{http_code}" `
  -X POST `
  -H "Authorization: Bearer $token" `
  -H "apikey: $anon" `
  -H "Expect:" `
  -H "Content-Type: application/vnd.android.package-archive" `
  -H "x-upsert: true" `
  --data-binary "@$temp" `
  $dest
$code = $upCode.Trim()
if ($code -ne '200' -and $code -ne '201') {
  throw "Upload HTTP $code"
}

$publicUrl = "$url/storage/v1/object/public/apk/$objectPath"
$force = [bool]$ForceUpdate.IsPresent
$patchBody = @{
  latest_version = $LatestVersion
  version_code   = $VersionCode
  sha256         = $sha
  apk_url        = $publicUrl
  changelog      = $Changelog
  force_update   = $force
} | ConvertTo-Json -Compress
$patchFile = Join-Path $env:TEMP 'wam_patch.json'
[System.IO.File]::WriteAllText($patchFile, $patchBody)
$patchOut = Join-Path $env:TEMP 'wam_patch_out.txt'
$patchCode = curl.exe --http1.1 -sS -o $patchOut -w "%{http_code}" `
  -X PATCH "$url/rest/v1/app_config?id=eq.1" `
  -H "Authorization: Bearer $token" `
  -H "apikey: $anon" `
  -H "Content-Type: application/json" `
  -H "Prefer: return=minimal" `
  --data-binary "@$patchFile"
if ($patchCode.Trim() -ne '200' -and $patchCode.Trim() -ne '204') {
  throw "PATCH app_config HTTP $($patchCode.Trim())"
}

Write-Output "HTTP $code"
Write-Output "version_code=$VersionCode"
Write-Output "latest_version=$LatestVersion"
Write-Output "sha256=$sha"
Write-Output "apk_url=$publicUrl"
Write-Output "force_update=$force"
Write-Output "changelog=$Changelog"
Write-Output "app_config=patched"
