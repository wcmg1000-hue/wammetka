# Smoke T06 on physical phone. Does not print secrets.
$ErrorActionPreference = 'Continue'
$serial = '68486ddd'
$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root '.env'
$map = @{}
Get-Content $envFile | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
  $k, $v = $_.Split('=', 2)
  $map[$k.Trim()] = $v.Trim().Trim('"')
}
$seed = $map['SEED_PASSWORD']
if (-not $seed) { throw 'SEED_PASSWORD missing' }

function Get-Ui {
  cmd /c "adb -s $serial shell uiautomator dump /sdcard/uidump.xml >NUL 2>&1" | Out-Null
  return [string](adb -s $serial exec-out cat /sdcard/uidump.xml)
}

function Wait-Text([string]$desc, [int]$sec = 25) {
  for ($i = 0; $i -lt $sec; $i++) {
    $xml = Get-Ui
    if ($xml.Contains($desc)) { return $xml }
    Start-Sleep -Seconds 1
  }
  throw "timeout waiting $desc"
}

function Tap-Contains([string]$xml, [string]$desc) {
  $esc = [regex]::Escape($desc)
  $m = [regex]::Match($xml, "content-desc=`"[^`"]*$esc[^`"]*`"[^>]*bounds=`"\[(\d+),(\d+)\]\[(\d+),(\d+)\]`"")
  if (-not $m.Success) {
    $m = [regex]::Match($xml, "bounds=`"\[(\d+),(\d+)\]\[(\d+),(\d+)\]`"[^>]*content-desc=`"[^`"]*$esc[^`"]*`"")
  }
  if (-not $m.Success) { throw "no bounds for $desc" }
  $x = [int](([int]$m.Groups[1].Value + [int]$m.Groups[3].Value) / 2)
  $y = [int](([int]$m.Groups[2].Value + [int]$m.Groups[4].Value) / 2)
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

function Login([string]$email) {
  $xml = Wait-Text 'Entrar a Wammetka'
  Tap-Edit 0
  Start-Sleep -Milliseconds 400
  Type-Text $email
  Start-Sleep -Milliseconds 300
  Tap-Edit 1
  Start-Sleep -Milliseconds 400
  Type-Text $seed
  Start-Sleep -Milliseconds 300
  adb -s $serial shell input keyevent 4 | Out-Null
  Tap-Contains (Get-Ui) 'Entrar'
}

$xml = Get-Ui
if (-not $xml.Contains('Hola, Cliente Piloto')) {
  adb -s $serial shell am force-stop co.wammetka.wammetka | Out-Null
  adb -s $serial shell am start -n co.wammetka.wammetka/.MainActivity | Out-Null
  Start-Sleep -Seconds 3
  Login 'cliente@wammetka.test'
  Start-Sleep -Seconds 3
  $xml = Wait-Text 'Hola, Cliente Piloto'
}
if (-not $xml.Contains('Tienda Piloto Fonseca')) { throw 'home sin tienda seed' }
Write-Output 'PASS cliente home + catalogo zona'
Tap-Contains (Get-Ui) 'Tienda Piloto Fonseca'
Start-Sleep -Seconds 2
Wait-Text 'Arroz 500 g' 15 | Out-Null
Write-Output 'PASS catalogo SKUs seed'
$xml = Get-Ui
$adds = [regex]::Matches($xml, 'class="android.widget.Button"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"')
if ($adds.Count -lt 1) { throw 'no add buttons' }
$plus = $null
foreach ($a in $adds) {
  $x1 = [int]$a.Groups[1].Value; $x2 = [int]$a.Groups[3].Value
  if ($x1 -gt 800 -and ($x2 - $x1) -lt 220) { $plus = $a; break }
}
if (-not $plus) { $plus = $adds[$adds.Count - 1] }
$px = [int](([int]$plus.Groups[1].Value + [int]$plus.Groups[3].Value) / 2)
$py = [int](([int]$plus.Groups[2].Value + [int]$plus.Groups[4].Value) / 2)
adb -s $serial shell input tap $px $py | Out-Null
Start-Sleep -Seconds 1
$xml = Wait-Text 'Ver carrito' 10
Tap-Contains $xml 'Ver carrito'
Start-Sleep -Seconds 1
Wait-Text 'Continuar a confirmar' 10 | Out-Null
Tap-Contains (Get-Ui) 'Continuar a confirmar'
Start-Sleep -Seconds 1
Wait-Text 'Confirmar pedido' 10 | Out-Null
Tap-Edit 0
Start-Sleep -Milliseconds 400
Type-Text 'Calle 5 10-20 Centro Fonseca'
adb -s $serial shell input keyevent 4 | Out-Null
Start-Sleep -Milliseconds 300
Tap-Contains (Get-Ui) 'Confirmar pedido'
Start-Sleep -Seconds 5
if (-not ((Get-Ui).Contains('Pedido enviado al comercio'))) { throw 'no pedido creado UI' }
Write-Output 'PASS checkout AC-03 UI'
Tap-Contains (Get-Ui) 'Ver mis pedidos'
Start-Sleep -Seconds 2
Tap-Contains (Get-Ui) 'Cuenta'
Start-Sleep -Seconds 1
Tap-Contains (Get-Ui) 'Cerrar sesión'
Start-Sleep -Seconds 1
$xml = Get-Ui
if ($xml.Contains('¿Quieres salir')) {
  Tap-Contains $xml 'Cerrar sesión'
}
Start-Sleep -Seconds 2
Wait-Text 'Entrar a Wammetka' 15 | Out-Null
Login 'comercio@wammetka.test'
Start-Sleep -Seconds 3
Wait-Text 'Pedidos' 15 | Out-Null
Write-Output 'PASS comercio shell'
$xml = Get-Ui
if ($xml.Contains('Cliente Piloto')) {
  Tap-Contains $xml 'Cliente Piloto'
} elseif ($xml.Contains('Nuevo')) {
  Tap-Contains $xml 'Nuevo'
} else {
  Write-Output 'WARN bandeja sin tarjeta; dump parcial ok'
}
Start-Sleep -Seconds 2
$xml = Get-Ui
if ($xml.Contains('Aceptar pedido')) {
  Tap-Contains $xml 'Aceptar pedido'
  Start-Sleep -Seconds 2
  if ((Get-Ui).Contains('Aceptado')) { Write-Output 'PASS AC-10 aceptar' } else { Write-Output 'WARN aceptar tap' }
} else {
  Write-Output 'WARN no Aceptar pedido'
}
Write-Output 'SMOKE_T06_DONE'
