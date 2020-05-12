$choco_success = @()
$choco_error = @()
$healthchecks_config = Get-Content -Raw -Path C:\itigo\config\healthchecks.json | ConvertFrom-Json
Invoke-WebRequest -Uri "$($healthchecks_config.HEALTHCHECK_URL)/ping/$($healthchecks_config.HEALTCHECKS_CHOCO_API_KEY)/start" -Method POST 
choco list --local-only --limit-output | ConvertFrom-Csv -Delimiter '|' -Header 'Name' | ForEach-Object {
    choco upgrade -y $_.Name
    if ($LASTEXITCODE -eq 0) {
        $choco_success += $_.Name
    }
    else {
        $choco_error += $_.Name
    }
}

if ($choco_error -gt 0) {
    Invoke-WebRequest -Uri "$($healthchecks_config.HEALTHCHECK_URL)/ping/$($healthchecks_config.HEALTCHECKS_CHOCO_API_KEY)/fail" -Method POST -Body "Error: $($choco_error -join ',') Success: $($choco_success -join ', ')" 
}
else {
    Invoke-WebRequest -Uri "$($healthchecks_config.HEALTHCHECK_URL)/ping/$($healthchecks_config.HEALTCHECKS_CHOCO_API_KEY)" -Method POST -Body "Success: $($choco_success -join ', ')" 
}
