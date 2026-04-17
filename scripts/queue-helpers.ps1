# queue-helpers.ps1 — Queue management helpers for PowerShell
#
# Add to your PowerShell profile:
#   notepad $PROFILE
#   Add the line:  . ~/repos/claude-shared/scripts/queue-helpers.ps1
#   Restart PowerShell

$QueueDir = "$HOME\repos\claude-shared\queue"
$ArchiveDir = "$HOME\repos\claude-shared\queue\archive"

# Move ticket files from Downloads to the queue
# Usage: qtix                     (moves all 2026-*.md from Downloads)
#        qtix somefile.md          (moves specific file)
function qtix {
    param([string[]]$Files)

    if (-not (Test-Path $QueueDir)) {
        Write-Host "Queue directory not found: $QueueDir" -ForegroundColor Red
        return
    }

    if ($Files.Count -eq 0) {
        $Downloads = "$HOME\Downloads"
        $Found = Get-ChildItem "$Downloads\2026-*.md" -ErrorAction SilentlyContinue
        if (-not $Found) {
            Write-Host "No ticket files (2026-*.md) found in $Downloads" -ForegroundColor Yellow
            return
        }
        $Found | Move-Item -Destination $QueueDir -Verbose
    } else {
        foreach ($f in $Files) {
            Move-Item -Path $f -Destination $QueueDir -Verbose
        }
    }

    Write-Host ""
    Write-Host "Queue contents:" -ForegroundColor Cyan
    qlist
}

# List what's in the queue
function qlist {
    $items = Get-ChildItem "$QueueDir\*.md" -ErrorAction SilentlyContinue
    if ($items) {
        $items | Sort-Object Name | ForEach-Object { Write-Host "  $($_.Name)" }
    } else {
        Write-Host "  (empty)" -ForegroundColor DarkGray
    }
}

# Peek at a ticket in the queue
function qpeek {
    param([string]$Name)

    if ($Name) {
        $file = Get-ChildItem "$QueueDir\$Name*" | Select-Object -First 1
    } else {
        $file = Get-ChildItem "$QueueDir\*.md" | Sort-Object Name | Select-Object -First 1
    }

    if ($file) {
        Write-Host "--- $($file.Name) ---" -ForegroundColor Cyan
        Get-Content $file.FullName
    } else {
        Write-Host "(queue is empty)" -ForegroundColor DarkGray
    }
}

Write-Host "Queue helpers loaded: qtix, qlist, qpeek" -ForegroundColor DarkGray
