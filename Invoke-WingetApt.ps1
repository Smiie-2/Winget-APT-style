param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs
)

# Function to run original winget
function Invoke-OriginalWinget {
    param([string[]]$Arguments)
    # Use where.exe to find the actual winget executable, avoiding our alias
    $wingetPath = (where.exe winget.exe | Select-Object -First 1)
    if (-not $wingetPath) {
        Write-Error "winget.exe not found in PATH."
        return
    }
    & $wingetPath $Arguments
}

if ($RemainingArgs.Count -eq 0) {
    Invoke-OriginalWinget
    exit $LASTEXITCODE
}

$command = $RemainingArgs[0]
$subArgs = $RemainingArgs[1..($RemainingArgs.Count - 1)]

# Only intercept 'install' or 'i' commands
if ($command -in @('install', 'i') -and $subArgs.Count -gt 0) {
    # Extract the package query (usually the first argument after 'install')
    # This is a simplified approach; more complex winget flags might need better parsing
    $query = $subArgs[0]
    
    # Check if the query looks like a flag
    if ($query.StartsWith("-")) {
        Invoke-OriginalWinget $RemainingArgs
        exit $LASTEXITCODE
    }

    Write-Host "Searching for '$query'..." -ForegroundColor Cyan
    
    # Run winget search and capture output
    $searchOutput = Invoke-OriginalWinget @('search', $query)
    
    # Winget output usually has a header like Name ID Version Source
    # We need to find where the actual results start
    $results = $searchOutput | Where-Object { $_ -match '^\S' -and $_ -notmatch '^Name\s+Id\s+Version' -and $_ -notmatch '^-+\s+-+' }

    if (-not $results) {
        Write-Host "No packages found matching '$query'." -ForegroundColor Yellow
        exit 0
    }

    if ($results.Count -eq 1) {
        # One match, just install it
        Write-Host "Found one match, proceeding with installation..." -ForegroundColor Green
        Invoke-OriginalWinget $RemainingArgs
        exit $LASTEXITCODE
    }

    # Multiple matches found
    Write-Host "Multiple matches found. Please select a package to install:" -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $results.Count; $i++) {
        Write-Host ("[{0}] {1}" -f ($i + 1), $results[$i])
    }

    $selection = Read-Host "Enter the number (1-$($results.Count)) or 'q' to quit"
    
    if ($selection -eq 'q') {
        Write-Host "Cancelled."
        exit 0
    }

    if ([int]::TryParse($selection, [ref]$index) -and $index -ge 1 -and $index -le $results.Count) {
        # Parse the ID from the selected line
        # Winget Search output is usually columnar. 
        # A simple split might not work if names have spaces.
        # But winget list/search output columns are fixed width or tabbed-ish.
        # Most reliable is to extract the ID column.
        $selectedLine = $results[$index - 1]
        
        # Heuristic: Find the ID. Usually the second column.
        # We'll try to find the ID by looking for the first gap of multiple spaces.
        if ($selectedLine -match '^(?<name>.+?)\s{2,}(?<id>\S+)\s+') {
            $id = $matches['id']
            Write-Host "Installing $id..." -ForegroundColor Green
            # We replace the query with the exact ID to prevent prompt again
            $newArgs = @($command, $id) + $subArgs[1..($subArgs.Count - 1)]
            Invoke-OriginalWinget $newArgs
        } else {
            # Fallback to the original line if parsing fails
            Write-Warning "Could not parse package ID. Falling back to original command."
            Invoke-OriginalWinget $RemainingArgs
        }
    } else {
        Write-Error "Invalid selection."
        exit 1
    }
} else {
    # Not an install command, pass through
    Invoke-OriginalWinget $RemainingArgs
    exit $LASTEXITCODE
}
