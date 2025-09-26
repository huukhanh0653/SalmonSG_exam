#!/bin/bash
# Wine Search API - Automated Test Runner
# Requires Newman (npm install -g newman)

echo "🍷 Wine Search API - Automated Test Suite"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Newman is installed
if ! command -v newman &> /dev/null; then
    echo -e "${RED}❌ Newman is not installed. Installing...${NC}"
    npm install -g newman
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install Newman. Please install manually: npm install -g newman${NC}"
        exit 1
    fi
fi

# Check if services are running
echo -e "${BLUE}🔍 Checking service availability...${NC}"

# Check Node.js service
if curl -s -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Node.js service is running on port 3000${NC}"
else
    echo -e "${RED}❌ Node.js service is not running. Please start it first.${NC}"
    echo -e "${YELLOW}💡 Run: cd Nodejs && npm start${NC}"
    exit 1
fi

# Check FastAPI service
if curl -s -f http://127.0.0.1:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ FastAPI service is running on port 8000${NC}"
else
    echo -e "${RED}❌ FastAPI service is not running. Please start it first.${NC}"
    echo -e "${YELLOW}💡 Run: cd FastAPI && python main.py${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🧪 Running automated test suite...${NC}"
echo ""

# Run tests with Newman
newman run wine-search-api-tests.postman_collection.json \
    --environment wine-search-test-environment.postman_environment.json \
    --reporters html,cli,json \
    --reporter-html-export ./test-results/test-report.html \
    --reporter-json-export ./test-results/test-results.json \
    --delay-request 100 \
    --timeout-request 5000 \
    --color on

# Check test results
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
    echo -e "${BLUE}📊 Test report generated: ./test-results/test-report.html${NC}"
else
    echo ""
    echo -e "${RED}❌ Some tests failed. Check the report for details.${NC}"
    echo -e "${BLUE}📊 Test report: ./test-results/test-report.html${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}📋 Test Summary:${NC}"
echo -e "${BLUE}• HTML Report: ./test-results/test-report.html${NC}"
echo -e "${BLUE}• JSON Results: ./test-results/test-results.json${NC}"
echo ""