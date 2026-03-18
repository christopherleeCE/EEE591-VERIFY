$answer = Read-Host "This will DELETE all local changes and untracked files. Continue? (y/n)"

if ($answer -ne 'y' -and $answer -ne 'Y') {
    Write-Output "Aborted."
    exit 1
}

git fetch --all
git reset --hard origin/main
git clean -fd
