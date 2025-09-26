@echo off
chcp 65001 >nul 2>&1
REM Wine Search API - Automated Test Runner for Windows
REM Requires Newman (npm install -g newman)

echo Wine Search API - Automated Test Suite
echo =========================================

REM Check if Newman is installed
newman --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Newman is not installed. Installing...
    call npm install -g newman
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Newman. Please install manually: npm install -g newman
        pause
        exit /b 1
    )
)

echo [INFO] Checking service availability...

REM Check Node.js service
curl -s -f http://localhost:3000/health >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Node.js service is running on port 3000
) else (
    echo [ERROR] Node.js service is not running. Please start it first.
    echo [TIP] Run: cd Nodejs ^&^& npm start
    pause
    exit /b 1
)

REM Check FastAPI service
curl -s -f http://127.0.0.1:8000/health >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] FastAPI service is running on port 8000
) else (
    echo [ERROR] FastAPI service is not running. Please start it first.
    echo [TIP] Run: cd FastAPI ^&^& python main.py
    pause
    exit /b 1
)

echo.
echo [INFO] Running automated test suite...
echo.

REM Create test-results directory if it doesn't exist
if not exist "test-results" mkdir test-results

REM Run tests with Newman
call newman run wine-search-api-tests.postman_collection.json ^
    --environment wine-search-test-environment.postman_environment.json ^
    --reporters html,cli,json ^
    --reporter-html-export ./test-results/test-report.html ^
    --reporter-json-export ./test-results/test-results.json ^
    --delay-request 100 ^
    --timeout-request 5000 ^
    --color on

if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] All tests passed successfully!
    echo [INFO] Test report generated: ./test-results/test-report.html
) else (
    echo.
    echo [ERROR] Some tests failed. Check the report for details.
    echo [INFO] Test report: ./test-results/test-report.html
)

echo.
echo [SUMMARY] Test Summary:
echo • HTML Report: ./test-results/test-report.html
echo • JSON Results: ./test-results/test-results.json
echo.

REM Open test report in default browser
start ./test-results/test-report.html

pause