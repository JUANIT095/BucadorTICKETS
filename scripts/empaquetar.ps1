# Prepara la distribucion portable de BuscadorTickets (Fase 20).
#   1. flutter build windows --release (se omite con -SinCompilar)
#   2. verifica que esten todos los archivos necesarios
#   3. copia la carpeta a dist\BuscadorTickets (sin data_usuario)
#   4. crea dist\BuscadorTickets-<version>-windows-x64.zip y su SHA-256
# Uso: powershell -ExecutionPolicy Bypass -File scripts\empaquetar.ps1 [-SinCompilar]

param([switch]$SinCompilar)
$ErrorActionPreference = 'Stop'

$proyecto = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$release = Join-Path $proyecto 'build\windows\x64\runner\Release'
$dist = Join-Path $proyecto 'dist'

$linea = Select-String -Path (Join-Path $proyecto 'pubspec.yaml') -Pattern '^version:\s*([0-9.]+)'
if (-not $linea) { throw 'No se encontro la version en pubspec.yaml' }
$version = $linea.Matches[0].Groups[1].Value

if (-not $SinCompilar) {
  Push-Location $proyecto
  try {
    & flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw 'flutter build windows --release fallo' }
  } finally { Pop-Location }
}

$necesarios = @(
  'BuscadorTickets.exe', 'flutter_windows.dll', 'file_selector_windows_plugin.dll',
  'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll', 'LEEME.txt',
  'data\icudtl.dat', 'data\app.so', 'data\flutter_assets'
)
$faltan = $necesarios | Where-Object { -not (Test-Path (Join-Path $release $_)) }
if ($faltan) { throw "Faltan archivos en la carpeta Release: $($faltan -join ', ')" }

$carpeta = Join-Path $dist 'BuscadorTickets'
if (Test-Path $carpeta) { Remove-Item -Recurse -Force $carpeta }
New-Item -ItemType Directory -Force $carpeta | Out-Null
# data_usuario solo existe si se ejecuto la app desde Release: es configuracion
# local de este PC y no se entrega.
Get-ChildItem $release | Where-Object { $_.Name -ne 'data_usuario' } |
  Copy-Item -Destination $carpeta -Recurse

$zip = Join-Path $dist "BuscadorTickets-$version-windows-x64.zip"
if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path $carpeta -DestinationPath $zip
$hash = (Get-FileHash $zip -Algorithm SHA256).Hash
"$hash  $(Split-Path $zip -Leaf)" | Set-Content -Encoding ascii "$zip.sha256"

$archivos = @(Get-ChildItem $carpeta -Recurse -File)
$mb = ($archivos | Measure-Object Length -Sum).Sum / 1MB
''
"Distribucion lista (version $version):"
"  Carpeta: $carpeta ($($archivos.Count) archivos, $('{0:N1}' -f $mb) MB)"
"  ZIP:     $zip ($('{0:N1}' -f ((Get-Item $zip).Length / 1MB)) MB)"
"  SHA-256: $hash"
