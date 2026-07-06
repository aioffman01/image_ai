# Windows Release Build & Self-Signing Automation Script

$ErrorActionPreference = "Stop"

Write-Host "1. Building Flutter Windows app in Release mode..." -ForegroundColor Cyan
Set-Location -Path "frontend"
& C:\Users\redof\flutter\bin\flutter.bat build windows --release --no-tree-shake-icons
if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed!"
    Exit 1
}
Set-Location -Path ".."

Write-Host "2. Copying release files to setup.win.d..." -ForegroundColor Cyan
if (!(Test-Path "setup.win.d")) {
    New-Item -ItemType Directory -Path "setup.win.d"
}
Copy-Item -Path "frontend\build\windows\x64\runner\Release\*" -Destination "setup.win.d" -Recurse -Force

Write-Host "3. Checking/Creating self-signed code signing certificate..." -ForegroundColor Cyan
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object { $_.Subject -like "*CN=LocalOcrApp*" } | Select-Object -First 1

if ($null -eq $cert) {
    $cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=LocalOcrApp" -CertStoreLocation "Cert:\CurrentUser\My"
    try {
        # Export and import to Trusted Root (CurrentUser scale doesn't strictly need Admin rights depending on policy)
        $certPath = "$env:TEMP\LocalOcrApp.cer"
        Export-Certificate -Cert $cert -FilePath $certPath
        Import-Certificate -FilePath $certPath -CertStoreLocation "Cert:\CurrentUser\Root"
        Remove-Item -Path $certPath -Force
        Write-Host "Successfully registered certificate in Trusted Root Certification Authorities." -ForegroundColor Green
    } catch {
        Write-Warning "Could not register certificate in Root store: $_. Try running PowerShell as Administrator."
    }
}

Write-Host "4. Signing local_ocr_app.exe..." -ForegroundColor Cyan
$signResult = Set-AuthenticodeSignature -FilePath "setup.win.d\local_ocr_app.exe" -Certificate $cert
$signResult | Format-List

Write-Host "Build & Sign Completed Successfully!" -ForegroundColor Green
