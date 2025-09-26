# Wine Search API - Test Documentation

## 🧪 Automated Testing với Postman và Newman

Hệ thống test tự động được thiết kế để kiểm tra cả FastAPI service và Node.js service với các test cases toàn diện.

## 📁 Test Files

```
SalmonTechTest/
├── wine-search-api-tests.postman_collection.json     # Postman collection
├── wine-search-test-environment.postman_environment.json  # Environment variables
├── run-tests.bat                                     # Windows test runner
├── run-tests.sh                                      # Linux/Mac test runner  
├── package.json                                      # Newman dependencies
└── test-results/                                     # Test reports (auto-generated)
    ├── test-report.html
    └── test-results.json
```

## 🚀 Cách chạy tests

### Bước 1: Cài đặt Newman (Postman CLI)
```bash
npm install -g newman
```

### Bước 2: Khởi động các services
```bash
# Terminal 1 - Node.js service
cd Nodejs
npm start

# Terminal 2 - FastAPI service  
cd FastAPI
python main.py
```

### Bước 3: Chạy automated tests

**Windows:**
```cmd
run-tests.bat
```

**Linux/Mac:**
```bash
chmod +x run-tests.sh
./run-tests.sh
```

**Manual Newman command:**
```bash
newman run wine-search-api-tests.postman_collection.json \
    --environment wine-search-test-environment.postman_environment.json \
    --reporters html,cli
```

## 📊 Test Categories

### 1. FastAPI Service Tests
- ✅ Health check endpoint
- ✅ Root endpoint  
- ✅ Search functionality (valid requests)
- ✅ Search by name, brand, origin
- ✅ Error handling (missing parameters)
- ✅ Error handling (invalid search terms)

### 2. Node.js Service Tests  
- ✅ Health check endpoint
- ✅ Direct search functionality
- ✅ Data validation

### 3. Performance Tests
- ✅ Response time validation (< 1 second)
- ✅ Load testing with random search values
- ✅ Memory usage monitoring

## 📋 Test Cases Chi Tiết

### ✅ Functional Tests

| Test Case | Endpoint | Expected Result |
|-----------|----------|-----------------|
| Health Check - FastAPI | `GET /health` | Status 200, correct JSON structure |
| Health Check - Node.js | `GET /health` | Status 200, data loaded confirmation |
| Search by Name | `POST /search?search_term=name&value=hennessy` | Array of wine objects |
| Search by Brand | `POST /search?search_term=brand&value=hennessy` | Filtered results by brand |
| Search by Origin | `POST /search?search_term=origin&value=france` | Filtered results by origin |
| Missing Parameters | `POST /search` | Status 400, error message |
| Invalid Search Term | `POST /search?search_term=invalid&value=test` | Status 400, "not found" error |

### ✅ Validation Tests

**Response Structure Validation:**
```json
{
  "name": "string",
  "brand": "string", 
  "origin": "string",
  "price": "number",
  "year": "number", 
  "matched_score": "number"
}
```

**Performance Validation:**
- Response time < 500ms for health checks
- Response time < 2000ms for search operations
- Response time < 1000ms for load tests

## 🔧 Test Configuration

### Environment Variables
```json
{
  "fastapi_base_url": "http://127.0.0.1:8000",
  "nodejs_base_url": "http://localhost:3000",
  "test_search_term": "name",
  "test_search_value": "hennessy"
}
```

### Newman Options
```bash
--reporters html,cli,json          # Multiple report formats
--reporter-html-export report.html # HTML report output
--delay-request 100                # 100ms delay between requests
--timeout-request 5000             # 5 second timeout
--iteration-count 10               # Run 10 iterations for load test
```

## 📊 Test Reports

### HTML Report
- Comprehensive test results with charts
- Response time graphs
- Pass/fail statistics
- Detailed error messages

### JSON Report  
- Machine-readable results
- Integration with CI/CD pipelines
- Performance metrics data

### CLI Report
- Real-time test execution feedback
- Color-coded results
- Summary statistics

## 🚀 Advanced Testing

### Load Testing
```bash
# Run 50 iterations with 25ms delay
npm run test:performance
```

### Custom Test Scenarios
```bash
# Run specific test folder
newman run collection.json --folder "FastAPI Service Tests"

# Run with custom iterations
newman run collection.json --iteration-count 100

# Run with data file
newman run collection.json --iteration-data test-data.csv
```

## 🐛 Troubleshooting

### Common Issues

**Newman not found:**
```bash
npm install -g newman
# or
npx newman --version
```

**Service not running:**
- Check if Node.js service is on port 3000
- Check if FastAPI service is on port 8000
- Verify health endpoints manually

**Test failures:**
- Check service logs
- Verify CSV data is loaded
- Check network connectivity

### Debug Commands
```bash
# Test individual endpoints
curl http://localhost:3000/health
curl http://127.0.0.1:8000/health

# Verbose Newman output
newman run collection.json --verbose

# Test with postman logs
newman run collection.json --postman-api-key YOUR_KEY
```

## 📈 CI/CD Integration

### GitHub Actions Example
```yaml
name: API Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '16'
    - name: Install Newman
      run: npm install -g newman
    - name: Start Services
      run: |
        cd Nodejs && npm install && npm start &
        cd ../FastAPI && pip install -r requirements.txt && python main.py &
        sleep 10
    - name: Run Tests
      run: newman run wine-search-api-tests.postman_collection.json --environment wine-search-test-environment.postman_environment.json
```

## 📊 Test Metrics

### Success Criteria
- ✅ All functional tests pass (100%)
- ✅ Response time < 2 seconds (95th percentile)
- ✅ Error rate < 1%
- ✅ Memory usage stable
- ✅ No memory leaks detected

### Performance Benchmarks
- Health check: < 100ms
- Search operations: < 1000ms
- Concurrent requests: 50 RPS
- Data loading: < 5 seconds

---

**Tác giả:** GitHub Copilot  
**Phiên bản:** 1.0.0  
**Cập nhật:** September 2025