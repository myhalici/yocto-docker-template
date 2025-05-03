# run.ps1
# Run setup-env.sh in current directory without specifying any path manually

# Check if bash is available
if (-not (Get-Command "bash" -ErrorAction SilentlyContinue)) {
    $bashPath = "C:\Program Files\Git\bin\bash.exe"
    if (Test-Path $bashPath) {
        Write-Host "Bash not in PATH. Setting alias to '$bashPath'"
        Set-Alias -Name bash -Value $bashPath
        # Run setup-env.sh using bash in the current directory
        bash ./setup-env.sh
    } else {
        Write-Host "Git Bash not found at expected path: $bashPath"
        Write-Host "Please install Git for Windows or update the path."
        exit 1
    }
} else {
    Write-Host "Bash is available: $(Get-Command bash)."
    # Run setup-env.sh using bash in the current directory
    bash ./setup-env.sh
}


