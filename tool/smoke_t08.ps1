# Smoke T08 on physical phone. Does not print secrets.
$ErrorActionPreference = 'Continue'
$serial = '68486ddd'
$root = Split-Path -Parent $PSScriptRoot
$map = @{}
Get-Content (Join-Path $root '.env') | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
  $k, $v = $_.Split('=', 2)
  $map[$k.Trim()] = $v.Trim().Trim('"')
}
$seed = $map['SEED_PASSWORD']
if (-not $seed) { throw 'SEED_PASSWORD missing' }

function Get-Ui {
  cmd /c "adb -s $serial shell uiautomator dump /sdcard/uidump.xml >NUL 2>&1" | Out-Null
  adb -s $serial exec-out cat /sdcard/uidump.xml | Out-File -Encoding utf8 "$env:TEMP\wam_ui.xml"
  return Get-Content "$env:TEMP\wam_ui.xml" -Raw
}
function Labels([string]$xml) {
  $vals = [regex]::Matches($xml, 'content-desc="([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
  return ($vals -join ' | ')
}
function Tap-Contains([string]$xml, [string]$desc) {
  $esc = [regex]::Escape($desc)
  $patternA = 'content-desc="[^"]*' + $esc + '[^"]*"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"'
  $patternB = 'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"[^>]*content-desc="[^"]*' + $esc + '[^"]*"'
  $ms = [regex]::Matches($xml, $patternA)
  if ($ms.Count -eq 0) { $ms = [regex]::Matches($xml, $patternB) }
  if ($ms.Count -eq 0) { throw "no $desc" }
  $m = $ms[$ms.Count - 1]
  $x = [int](([int]$m.Groups[1].Value + [int]$m.Groups[3].Value) / 2)
  $y = [int](([int]$m.Groups[2].Value + [int]$m.Groups[4].Value) / 2)
  Write-Output "tap $desc $x $y"
  adb -s $serial shell input tap $x $y | Out-Null
}
function Tap-Edit([int]$index) {
  $xml = Get-Ui
  $ms = [regex]::Matches($xml, 'class="android.widget.EditText"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"')
  if ($ms.Count -le $index) {
    $ms = [regex]::Matches($xml, 'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"[^>]*class="android.widget.EditText"')
  }
  if ($ms.Count -le $index) { throw "edit $index not found" }
  $m = $ms[$index]
  $x = [int](([int]$m.Groups[1].Value + [int]$m.Groups[3].Value) / 2)
  $y = [int](([int]$m.Groups[2].Value + [int]$m.Groups[4].Value) / 2)
  adb -s $serial shell input tap $x $y | Out-Null
}
function Type-Text([string]$value) {
  $escaped = $value.Replace(' ', '%s').Replace('@', '\@').Replace('&', '\&').Replace('#', '\#')
  adb -s $serial shell input text $escaped | Out-Null
}

adb -s $serial shell svc power stayon true | Out-Null
adb -s $serial shell input keyevent KEYCODE_WAKEUP
Start-Sleep -Milliseconds 400
adb -s $serial shell wm dismiss-keyguard
Start-Sleep -Milliseconds 300
adb -s $serial shell am force-stop co.wammetka.wammetka
Start-Sleep -Seconds 1
adb -s $serial shell am start -n co.wammetka.wammetka/.MainActivity
Start-Sleep -Seconds 8
Write-Output ("boot {0}" -f (Labels (Get-Ui)))

Tap-Edit 0
Start-Sleep -Milliseconds 400
Type-Text 'reparto@wammetka.test'
Start-Sleep -Milliseconds 300
Tap-Edit 1
Start-Sleep -Milliseconds 400
Type-Text $seed
Start-Sleep -Milliseconds 300
adb -s $serial shell input keyevent 4 | Out-Null
Tap-Contains (Get-Ui) 'Entrar'
Start-Sleep -Seconds 7
$xml = Get-Ui
Write-Output ("afterLogin {0}" -f (Labels $xml))
if ($xml.Contains('No hay red') -or $xml.Contains('incorrectos') -or $xml.Contains('correo válido')) {
  Write-Output 'LOGIN_FAIL'
  exit 2
}

if (-not $xml.Contains('A6FB5A34')) {
  Write-Output 'NO_OFFER'
  exit 3
}
Tap-Contains $xml 'A6FB5A34'
Start-Sleep -Seconds 3
$xml = Get-Ui
Write-Output ("detail {0}" -f (Labels $xml))
Tap-Contains $xml 'Aceptar servicio'
Start-Sleep -Seconds 3
$xml = Get-Ui
Write-Output ("asignado {0}" -f (Labels $xml))
Tap-Contains $xml 'Marcar recogido'
Start-Sleep -Seconds 3
$xml = Get-Ui
Write-Output ("recogido {0}" -f (Labels $xml))
Tap-Edit 0
Start-Sleep -Milliseconds 400
Type-Text 'Entregado en porteria'
Start-Sleep -Milliseconds 400
adb -s $serial shell input keyevent 4 | Out-Null
Tap-Contains (Get-Ui) 'Marcar entregado'
Start-Sleep -Seconds 4
$xml = Get-Ui
Write-Output ("entregado {0}" -f (Labels $xml))
if ($xml.Contains('Entregado')) { Write-Output 'SMOKE_OK' } else { Write-Output 'SMOKE_UI_PARTIAL' }
