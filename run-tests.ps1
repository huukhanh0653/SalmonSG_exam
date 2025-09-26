# Wine Search API - Automated Test Runner (PowerShell)
# Requires Newman (npm install -g newman)

Write-Host "Wine Search API - Automated Test Suite" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check if Newman is installed
try {
    $null = Get-Command newman -ErrorAction Stop
    Write-Host "[OK] Newman is installed" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Newman is not installed. Installing..." -ForegroundColor Red
    try {
        npm install -g newman
        if ($LASTEXITCODE -ne 0) {
            throw "Newman installation failed"
        }
        Write-Host "[OK] Newman installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to install Newman. Please install manually: npm install -g newman" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host "[INFO] Checking service availability..." -ForegroundColor Blue

# Check Node.js service
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method Get -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] Node.js service is running on port 3000" -ForegroundColor Green
    } else {
        throw "Invalid response"
    }
} catch {
    Write-Host "[ERROR] Node.js service is not running. Please start it first." -ForegroundColor Red
    Write-Host "[TIP] Run: cd Nodejs && npm start" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check FastAPI service
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -Method Get -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] FastAPI service is running on port 8000" -ForegroundColor Green
    } else {
        throw "Invalid response"
    }
} catch {
    Write-Host "[ERROR] FastAPI service is not running. Please start it first." -ForegroundColor Red
    Write-Host "[TIP] Run: cd FastAPI && python main.py" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[INFO] Running automated test suite..." -ForegroundColor Blue
Write-Host ""

# Create test-results directory if it doesn't exist
if (!(Test-Path "test-results")) {
    New-Item -ItemType Directory -Path "test-results" | Out-Null
}

# Run tests with Newman
try {
    $newmanArgs = @(
        "run", "wine-search-api-tests.postman_collection.json",
        "--environment", "wine-search-test-environment.postman_environment.json",
        "--reporters", "html,cli,json",
        "--reporter-html-export", "./test-results/test-report.html",
        "--reporter-json-export", "./test-results/test-results.json",
        "--delay-request", "100",
        "--timeout-request", "5000",
        "--color", "on"
    )
    
    & newman $newmanArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[SUCCESS] All tests passed successfully!" -ForegroundColor Green
        Write-Host "[INFO] Test report generated: ./test-results/test-report.html" -ForegroundColor Blue
    } else {
        Write-Host ""
        Write-Host "[ERROR] Some tests failed. Check the report for details." -ForegroundColor Red
        Write-Host "[INFO] Test report: ./test-results/test-report.html" -ForegroundColor Blue
    }
} catch {
    Write-Host "[ERROR] Failed to run Newman tests: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[SUMMARY] Test Summary:" -ForegroundColor Yellow
Write-Host "• HTML Report: ./test-results/test-report.html" -ForegroundColor Blue
Write-Host "• JSON Results: ./test-results/test-results.json" -ForegroundColor Blue
Write-Host ""

# Open test report in default browser
try {
    if (Test-Path "./test-results/test-report.html") {
        Write-Host "[INFO] Opening test report in browser..." -ForegroundColor Blue
        Start-Process "./test-results/test-report.html"
    }
} catch {
    Write-Host "[WARNING] Could not open test report automatically" -ForegroundColor Yellow
}

Read-Host "Press Enter to exit"