# run.ps1
# Run setup-env.sh in current directory without specifying any path manually

# Check if bash is available
if (-not (Get-Command bash.exe -ErrorAction SilentlyContinue)) {
    Write-Host "Bash not found. Please make sure Git Bash is installed and added to PATH." -ForegroundColor Red
    exit 1
}

# Run setup-env.sh using bash in the current directory
bash ./setup-env.sh
