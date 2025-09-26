# Quick Test Script for Wine Search API
# Run this in PowerShell

Write-Host "Wine Search API - Quick Test" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

# Step 1: Check if we're in the right directory
$currentDir = Get-Location
Write-Host "Current directory: $currentDir" -ForegroundColor Yellow

# Step 2: Start Node.js service
Write-Host "[1/4] Starting Node.js service..." -ForegroundColor Blue
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'D:\Code Files\SalmonTechTest\Nodejs'; node index.js" -WindowStyle Normal

# Wait for service to start
Write-Host "Waiting for Node.js service to start..." -ForegroundColor Yellow
Start-Sleep 5

# Step 3: Test Node.js service
Write-Host "[2/4] Testing Node.js service..." -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method Get -TimeoutSec 5
    Write-Host "Node.js service is running!" -ForegroundColor Green
    Write-Host "Record count: $($response.recordCount)" -ForegroundColor Green
} catch {
    Write-Host "Node.js service failed to start: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Start FastAPI service  
Write-Host "[3/4] Starting FastAPI service..." -ForegroundColor Blue
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'D:\Code Files\SalmonTechTest\FastAPI'; & 'D:/Code Files/SalmonTechTest/.venv/Scripts/python.exe' main.py" -WindowStyle Normal

# Wait for service to start
Write-Host "Waiting for FastAPI service to start..." -ForegroundColor Yellow  
Start-Sleep 5

# Step 5: Test FastAPI service
Write-Host "[4/4] Testing FastAPI service..." -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8000/health" -Method Get -TimeoutSec 5
    Write-Host "FastAPI service is running!" -ForegroundColor Green
    Write-Host "Node.js connection: $($response.nodejs_server.status)" -ForegroundColor Green
} catch {
    Write-Host "FastAPI service failed to start: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "All services are running! Now you can run tests:" -ForegroundColor Green
Write-Host "• PowerShell: .\run-tests.ps1" -ForegroundColor Yellow
Write-Host "• Batch: .\run-tests.bat" -ForegroundColor Yellow  
Write-Host "• Newman: newman run wine-search-api-tests.postman_collection.json --environment wine-search-test-environment.postman_environment.json" -ForegroundColor Yellow

Write-Host ""
Write-Host "Manual Test URLs:" -ForegroundColor Blue
Write-Host "• Node.js Health: http://localhost:3000/health" -ForegroundColor White
Write-Host "• FastAPI Health: http://127.0.0.1:8000/health" -ForegroundColor White
Write-Host "• FastAPI Docs: http://127.0.0.1:8000/docs" -ForegroundColor White