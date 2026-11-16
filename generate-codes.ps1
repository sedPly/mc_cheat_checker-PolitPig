# ============================================
# Code Generator - PowerShell Client
# Скрипт для генерации кодов через PowerShell
# ============================================
# Использование:
#   .\generate-codes.ps1 -Type promo -Length 16 -Count 5
#   .\generate-codes.ps1 -Type api -Prefix "sk_live" -Count 10
#   .\generate-codes.ps1 -Type password -Length 24 -Export
#   .\generate-codes.ps1 -Type uuid -Count 20 -Export -OutputPath ".\uuids.txt"
# ============================================

param(
    [ValidateSet("promo", "api", "password", "uuid", "hex", "pin")]
    [string]$Type = "promo",

    [ValidateRange(4, 64)]
    [int]$Length = 16,

    [ValidateRange(1, 1000)]
    [int]$Count = 1,

    [string]$Prefix = "",

    [switch]$Export,

    [string]$OutputPath = ".\codes_output.txt",

    [switch]$OpenSite,

    [string]$SiteUrl = ""
)

# Функция генерации кода
function New-Code {
    param(
        [string]$CodeType,
        [int]$CodeLength,
        [string]$CodePrefix
    )

    switch ($CodeType) {
        "promo" {
            $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            $result = if ($CodePrefix) { "$CodePrefix-" } else { "" }
            for ($i = 0; $i -lt $CodeLength; $i++) {
                $result += $chars[(Get-Random -Maximum $chars.Length)]
                if ((($i + 1) % 4 -eq 0) -and ($i -lt $CodeLength - 1)) {
                    $result += "-"
                }
            }
            return $result
        }
        "api" {
            $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
            $result = if ($CodePrefix) { "${CodePrefix}_" } else { "" }
            for ($i = 0; $i -lt $CodeLength; $i++) {
                $result += $chars[(Get-Random -Maximum $chars.Length)]
            }
            return $result
        }
        "password" {
            $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-="
            $result = ""
            for ($i = 0; $i -lt $CodeLength; $i++) {
                $result += $chars[(Get-Random -Maximum $chars.Length)]
            }
            return $result
        }
        "uuid" {
            return [guid]::NewGuid().ToString()
        }
        "hex" {
            $hex = "#"
            for ($i = 0; $i -lt 6; $i++) {
                $hex += "0123456789abcdef"[(Get-Random -Maximum 16)]
            }
            return $hex
        }
        "pin" {
            $result = ""
            $pinLength = [Math]::Min($CodeLength, 12)
            for ($i = 0; $i -lt $pinLength; $i++) {
                $result += (Get-Random -Maximum 10)
            }
            return $result
        }
    }
}

# Открыть сайт если указан флаг
if ($OpenSite -and $SiteUrl) {
    Start-Process $SiteUrl
    Write-Host ""
    Write-Host "Открыт сайт: $SiteUrl" -ForegroundColor Cyan
}

# Основная логика
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║       Code Generator - PowerShell        ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Тип: " -NoNewline -ForegroundColor DarkGray
Write-Host "$Type" -ForegroundColor Yellow -NoNewline
Write-Host " | Длина: " -NoNewline -ForegroundColor DarkGray
Write-Host "$Length" -ForegroundColor Yellow -NoNewline
Write-Host " | Кол-во: " -NoNewline -ForegroundColor DarkGray
Write-Host "$Count" -ForegroundColor Yellow
if ($Prefix) {
    Write-Host "  Префикс: " -NoNewline -ForegroundColor DarkGray
    Write-Host "$Prefix" -ForegroundColor Yellow
}
Write-Host "  ──────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

$codes = @()
$startTime = Get-Date

for ($i = 0; $i -lt $Count; $i++) {
    $code = New-Code -CodeType $Type -CodeLength $Length -CodePrefix $Prefix
    $codes += $code
    $num = $i + 1
    Write-Host "  [$($num.ToString().PadLeft(3))] " -NoNewline -ForegroundColor DarkGray
    Write-Host $code -ForegroundColor Green
}

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalMilliseconds

Write-Host ""
Write-Host "  ──────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  ✓ Сгенерировано: " -NoNewline -ForegroundColor Green
Write-Host "$($codes.Count) кодов" -ForegroundColor White -NoNewline
Write-Host " за " -NoNewline -ForegroundColor DarkGray
Write-Host "$([Math]::Round($duration, 2))ms" -ForegroundColor Cyan
Write-Host ""

# Экспорт в файл
if ($Export) {
    $codes | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "  💾 Экспортировано в: " -NoNewline -ForegroundColor DarkGray
    Write-Host "$OutputPath" -ForegroundColor Green
    Write-Host ""
}

# Копировать в буфер обмена если один код
if ($Count -eq 1) {
    $codes[0] | Set-Clipboard
    Write-Host "  📋 Код скопирован в буфер обмена!" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "  ══════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""
