$installDir = "$HOME\AppData\Local\winget-apt"
$scriptName = "Invoke-WingetApt.ps1"
$sourcePath = Join-Path $PSScriptRoot $scriptName
$destPath = Join-Path $installDir $scriptName

Write-Host "Installing winget-apt..." -ForegroundColor Cyan

# Create directory
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Copy script
Copy-Item -Path $sourcePath -Destination $destPath -Force
Write-Host "Script copied to $destPath" -ForegroundColor Green

# Define the alias function with $HOME instead of a hardcoded path
$aliasFunction = @"

# --- winget-apt wrapper ---
function winget {
    & "`$HOME\AppData\Local\winget-apt\Invoke-WingetApt.ps1" @args
}
# --------------------------
"@

# Helper function to update a profile
function Update-Profile {
    param([string]$path)
    if (Test-Path $path) {
        $content = Get-Content $path -Raw
        if ($content -notlike "*winget-apt wrapper*") {
            Add-Content -Path $path -Value $aliasFunction
            Write-Host "Updated profile: $path" -ForegroundColor Green
        }
        else {
            Write-Host "Alias already exists in: $path" -ForegroundColor Gray
        }
    }
}

# Update both common profile locations
Update-Profile -path "$HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Update-Profile -path "$HOME\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Update-Profile -path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Update-Profile -path "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

Write-Host "Installation complete!" -ForegroundColor Cyan
Write-Host "Please restart your terminal or run '. `$PROFILE' to enable the alias." -ForegroundColor Yellow
