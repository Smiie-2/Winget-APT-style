$installDir = "$HOME\AppData\Local\winget-apt"

Write-Host "Uninstalling winget-apt..." -ForegroundColor Cyan

# Remove the alias block from profile files
$startMarker = "# --- winget-apt wrapper ---"
$endMarker = "# --------------------------"

function Remove-AliasFromProfile {
    param([string]$path)
    if (Test-Path $path) {
        $lines = Get-Content $path
        $newLines = @()
        $skipping = $false
        foreach ($line in $lines) {
            if ($line.Trim() -eq $startMarker) {
                $skipping = $true
                continue
            }
            if ($skipping -and $line.Trim() -eq $endMarker) {
                $skipping = $false
                continue
            }
            if (-not $skipping) {
                $newLines += $line
            }
        }
        # Trim trailing blank lines left behind
        while ($newLines.Count -gt 0 -and [string]::IsNullOrWhiteSpace($newLines[-1])) {
            $newLines = $newLines[0..($newLines.Count - 2)]
        }
        Set-Content -Path $path -Value $newLines
        Write-Host "Cleaned profile: $path" -ForegroundColor Green
    }
}

$profiles = @(
    "$HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$HOME\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
)

foreach ($p in $profiles) {
    Remove-AliasFromProfile -path $p
}

# Remove installed files
if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
    Write-Host "Removed $installDir" -ForegroundColor Green
} else {
    Write-Host "Install directory not found, skipping." -ForegroundColor Gray
}

Write-Host "Uninstall complete!" -ForegroundColor Cyan
Write-Host "Please restart your terminal for changes to take effect." -ForegroundColor Yellow
