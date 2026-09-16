$ErrorActionPreference = 'Stop'
$testRoot = Join-Path $env:RUNNER_TEMP ([guid]::NewGuid().ToString())
$sourceRoot = Join-Path $testRoot 'device'
$scriptRoot = Join-Path $testRoot 'scripts'
$targetRoot = Join-Path $testRoot '音频日记'
New-Item -ItemType Directory -Path "$sourceRoot\RECORDER", $scriptRoot -Force | Out-Null
Copy-Item scripts/archive.ps1 $scriptRoot
@('# comment must not become the destination', '', $targetRoot) | Set-Content "$scriptRoot\config.txt" -Encoding UTF8
$name = 'Note-20260916083000.mp3'
[IO.File]::WriteAllBytes("$sourceRoot\RECORDER\$name", [byte[]](1,2,3,4))
$letter = @('E','F','G','H','I','J','K','L') | Where-Object { -not (Test-Path "${_}:\") } | Select-Object -First 1
if (-not $letter) { throw 'No free test drive' }
subst "${letter}:" $sourceRoot
if ($LASTEXITCODE -ne 0) { throw 'Could not create test drive' }
try {
  & "$scriptRoot\archive.ps1"
  $destination = "$targetRoot\2026年9月\16日\$name"
  if (-not (Test-Path $destination)) { throw 'Missing archived recording' }
  if ((Get-FileHash $destination).Hash -ne (Get-FileHash "$sourceRoot\RECORDER\$name").Hash) { throw 'Content differs' }
  & "$scriptRoot\archive.ps1"
  if (-not (Test-Path "$sourceRoot\RECORDER\$name")) { throw 'Source removed' }
} finally {
  subst "${letter}:" /D
  Remove-Item $testRoot -Recurse -Force
}
