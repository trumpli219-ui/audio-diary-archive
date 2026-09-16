# 音频日记归档脚本（通用版）

# 用法：归档 U盘 RECORDER 中的 mp3 到本地音频日记库按月/按日文件夹
# 不删除源文件，复制后校验
# 目标路径从脚本同目录的 config.txt 读取（若不存在则使用下方默认值）

param()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptDir "config.txt"

# 目标根目录：优先读 config.txt，否则用默认值
$dstRoot = $null
if (Test-Path $configFile) {
    $line = Get-Content $configFile -Encoding UTF8 -ErrorAction Stop | Where-Object { $_.Trim() -and -not $_.Trim().StartsWith("#") } | Select-Object -First 1
    if ($line -and $line.Trim().Length -gt 0) { $dstRoot = $line.Trim() }
}
if (-not $dstRoot) { throw "请先在 scripts/config.txt 中填写目标目录" }

# 自动探测 U盘 RECORDER 盘符
$usb = $null
foreach ($l in @("E:","F:","G:","H:","I:","J:","K:","L:")) {
    if (Test-Path "$l\RECORDER") { $usb = "$l\RECORDER"; break }
}
if (-not $usb) {
    Write-Output "未找到U盘RECORDER文件夹"
    exit 0
}

Write-Output "源: $usb"
Write-Output "目标: $dstRoot"

$srcFiles = Get-ChildItem "$usb\*.mp3" -ErrorAction SilentlyContinue | Sort-Object Name
if ($srcFiles.Count -eq 0) {
    Write-Output "没有待归档的音频文件"
    exit 0
}
Write-Output "发现 $($srcFiles.Count) 个待归档文件"

$copied = 0
$errors = @()

foreach ($f in $srcFiles) {
    if ($f.Name -match "Note-(\d{4})(\d{2})(\d{2})\d{6}\.mp3") {
        $year = $matches[1]
        $month = [int]$matches[2]
        $day = [int]$matches[3]

        $monthDir = "$dstRoot\${year}年${month}月"
        $dayDir = "$monthDir\${day}日"

        if (-not (Test-Path $dayDir)) {
            cmd /c "mkdir `"$dayDir`"" 2>$null
        }

        $result = cmd /c "copy /Y `"$($f.FullName)`" `"$dayDir\$($f.Name)`"" 2>&1
        if ($result -match "1 file\(s\) copied|已复制") {
            $copied++
        } else {
            $errors += "复制失败: $($f.Name) -> $dayDir"
        }
    }
}

$verifyErrors = 0
foreach ($f in $srcFiles) {
    if ($f.Name -match "Note-(\d{4})(\d{2})(\d{2})\d{6}\.mp3") {
        $year = $matches[1]
        $month = [int]$matches[2]
        $day = [int]$matches[3]
        $destFile = "$dstRoot\${year}年${month}月\${day}日\$($f.Name)"
        if (Test-Path $destFile) {
            $df = Get-Item $destFile
            if ($df.Length -ne $f.Length) { $verifyErrors++ }
        } else {
            $verifyErrors++
        }
    }
}

Write-Output "`n=== 归档结果 ==="
Write-Output "复制: $copied/$($srcFiles.Count)"
Write-Output "校验: $(if($verifyErrors -eq 0){'OK 全部通过'}else{"FAIL $verifyErrors 个不一致"})"
if ($errors.Count -gt 0) {
    Write-Output "错误:"
    $errors | ForEach-Object { Write-Output "  $_" }
}
