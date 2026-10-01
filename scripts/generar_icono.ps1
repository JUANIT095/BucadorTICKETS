# Genera windows/runner/resources/app_icon.ico (icono del .exe y de la ventana).
# Lupa roja sobre fondo negro con tres lineas blancas, como el icono del
# encabezado de la app. Solo usa System.Drawing (incluido en Windows).
# Uso: powershell -ExecutionPolicy Bypass -File scripts/generar_icono.ps1

Add-Type -AssemblyName System.Drawing
$destino = Join-Path $PSScriptRoot '..\windows\runner\resources\app_icon.ico'
$tamanos = 16, 20, 24, 32, 40, 48, 64, 128, 256

$negro = [System.Drawing.Color]::FromArgb(255, 11, 11, 13)
$rojo = [System.Drawing.Color]::FromArgb(255, 225, 29, 46)
$rojoProfundo = [System.Drawing.Color]::FromArgb(255, 122, 14, 24)
$blanco = [System.Drawing.Color]::FromArgb(255, 245, 245, 247)

function Dibujar([int]$n) {
  $bmp = New-Object System.Drawing.Bitmap $n, $n
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.Clear([System.Drawing.Color]::Transparent)

  # Fondo: cuadrado redondeado negro con brillo rojo difuminado.
  $r = [single]($n * 0.22)
  $fondo = New-Object System.Drawing.Drawing2D.GraphicsPath
  $fondo.AddArc(0, 0, 2 * $r, 2 * $r, 180, 90)
  $fondo.AddArc($n - 2 * $r - 1, 0, 2 * $r, 2 * $r, 270, 90)
  $fondo.AddArc($n - 2 * $r - 1, $n - 2 * $r - 1, 2 * $r, 2 * $r, 0, 90)
  $fondo.AddArc(0, $n - 2 * $r - 1, 2 * $r, 2 * $r, 90, 90)
  $fondo.CloseFigure()
  $g.FillPath((New-Object System.Drawing.SolidBrush $negro), $fondo)
  $brillo = New-Object System.Drawing.Drawing2D.PathGradientBrush $fondo
  $brillo.CenterPoint = New-Object System.Drawing.PointF ([single]($n * 0.3)), ([single]($n * 0.25))
  $brillo.CenterColor = [System.Drawing.Color]::FromArgb(150, $rojoProfundo)
  $brillo.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $negro))
  $g.FillPath($brillo, $fondo)

  # Lupa roja (circulo + mango).
  $grosor = [single][Math]::Max(1.6, $n * 0.09)
  $lapiz = New-Object System.Drawing.Pen $rojo, $grosor
  $lapiz.StartCap = 'Round'; $lapiz.EndCap = 'Round'
  $cx = $n * 0.60; $cy = $n * 0.44; $radio = $n * 0.19
  $g.DrawEllipse($lapiz, [single]($cx - $radio), [single]($cy - $radio), [single](2 * $radio), [single](2 * $radio))
  $d = $radio * 0.72
  $g.DrawLine($lapiz, [single]($cx + $d), [single]($cy + $d), [single]($n * 0.82), [single]($n * 0.80))

  # Tres lineas blancas a la izquierda (se omiten en tamanos muy pequenos).
  if ($n -ge 24) {
    $linea = New-Object System.Drawing.Pen $blanco, ([single]($n * 0.065))
    $linea.StartCap = 'Round'; $linea.EndCap = 'Round'
    $x0 = [single]($n * 0.17)
    $g.DrawLine($linea, $x0, [single]($n * 0.32), [single]($n * 0.32), [single]($n * 0.32))
    $g.DrawLine($linea, $x0, [single]($n * 0.50), [single]($n * 0.32), [single]($n * 0.50))
    $g.DrawLine($linea, $x0, [single]($n * 0.68), [single]($n * 0.56), [single]($n * 0.68))
  }
  $g.Dispose()
  $ms = New-Object System.IO.MemoryStream
  $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  return ,$ms.ToArray()
}

# Formato ICO con imagenes PNG (admitido desde Windows Vista).
$imagenes = foreach ($n in $tamanos) { ,(Dibujar $n) }
$salida = New-Object System.IO.MemoryStream
$w = New-Object System.IO.BinaryWriter $salida
$w.Write([uint16]0); $w.Write([uint16]1); $w.Write([uint16]$tamanos.Count)
$offset = 6 + 16 * $tamanos.Count
for ($i = 0; $i -lt $tamanos.Count; $i++) {
  $lado = if ($tamanos[$i] -ge 256) { 0 } else { $tamanos[$i] }
  $w.Write([byte]$lado); $w.Write([byte]$lado); $w.Write([byte]0); $w.Write([byte]0)
  $w.Write([uint16]1); $w.Write([uint16]32)
  $w.Write([uint32]$imagenes[$i].Length); $w.Write([uint32]$offset)
  $offset += $imagenes[$i].Length
}
foreach ($img in $imagenes) { $w.Write($img) }
$w.Flush()
[System.IO.File]::WriteAllBytes($destino, $salida.ToArray())
"Icono generado: $((Resolve-Path $destino).Path) ($($salida.Length) bytes)"
