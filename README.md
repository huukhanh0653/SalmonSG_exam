# Wine Search API System

A dual-service wine search system consisting of a Node.js backend service with fuzzy search capabilities and a FastAPI proxy service. The system allows users to search through a wine database using fuzzy matching algorithms.

## 🏗️ Architecture

```
┌─────────────────┐    HTTP Proxy    ┌─────────────────┐    CSV Data    ┌─────────────────┐
│   FastAPI       │ ────────────────► │   Node.js       │ ──────────────► │   Wine CSV      │
│   (Port 8000)   │                  │   (Port 3000)   │                │   Database      │
│   Proxy Layer   │                  │   Search Engine │                │                 │
└─────────────────┘                  └─────────────────┘                └─────────────────┘
```

## 📁 Project Structure

```
SalmonTechTest/
├── FastAPI/                 # Python FastAPI proxy service
│   ├── main.py             # FastAPI application
│   ├── requirements.txt    # Python dependencies
│   └── start_services.bat  # Service startup script
├── Nodejs/                 # Node.js wine search service
│   ├── model/
│   │   └── wine.js        # Wine data model with fuzzy search
│   ├── index.js           # Express.js server
│   ├── package.json       # Node.js dependencies
│   ├── .env               # Environment configuration
│   └── wine_database.csv  # Wine dataset
└── README.md
```

## 🚀 Services Overview

### Node.js Service (Port 3000)
- **Framework**: Express.js
- **Search Engine**: Fuse.js (fuzzy search)
- **Data Source**: CSV file with wine records
- **Pattern**: Singleton design pattern for data management

### FastAPI Service (Port 8000)  
- **Framework**: FastAPI (Python)
- **Role**: HTTP proxy and API gateway
- **Features**: Request forwarding, error handling, API documentation

## 📊 Data Model

### Wine Record Structure
```json
{
  "wine_id": "1",
  "full_name": "Hennessy Very Special Cognac",
  "brand": "Hennessy",
  "type": "Cognac", 
  "origin": "France",
  "alcohol_content": "40%",
  "price": "2500000",
  "year": "2023"
}
```

### API Response Format
```json
{
  "name": "Hennessy Very Special Cognac",
  "brand": "Hennessy",
  "type": "Cognac",
  "origin": "France", 
  "price": 2500000,
  "year": 2023,
  "matched_score": 0.95
}
```

## 🛠️ Setup & Installation

### Prerequisites
- Node.js (v14+)
- Python (v3.8+)
- npm or yarn

### 1. Node.js Service Setup

```bash
cd Nodejs
npm install
```

**Dependencies:**
- express: ^5.1.0
- csv-parser: ^3.2.0
- fuse.js: ^7.1.0  
- dotenv: ^17.2.2

### 2. FastAPI Service Setup

```bash
cd FastAPI
pip install -r requirements.txt
```

**Dependencies:**
- fastapi==0.104.1
- uvicorn[standard]==0.24.0
- httpx==0.25.2
- pydantic==2.5.0

### 3. Environment Configuration

Create/verify `.env` file in `Nodejs/` directory:
```env
PORT=3000
CSV_FILE=wine_database.csv
SEARCH_THRESHOLD=0.3
```

## 🚀 Running the Services

### Option 1: Manual Startup

**Start Node.js Service:**
```bash
cd Nodejs
npm start
# or
node index.js
```

**Start FastAPI Service:**
```bash
cd FastAPI
python main.py
# or  
uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

### Option 2: Automated Startup
```bash
cd FastAPI
./start_services.bat
```

## 📡 API Endpoints

### FastAPI Proxy Service (Port 8000)

#### 🔍 Search Wines
```http
POST /search?search_term=name&value=hennessy
```

**Parameters:**
- `search_term`: Field to search in (`name`, `brand`, `type`, `origin`)
- `value`: Search value

**Response:**
```json
[
  {
    "name": "Hennessy Paradis Imperial",
    "brand": "Hennessy",
    "type": "Cognac",
    "origin": "France",
    "price": 75000000,
    "year": 2023,
    "matched_score": 0.95
  }
]
```

#### 🏥 Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "OK",
  "service": "Wine Search Proxy API",
  "version": "1.0.0",
  "nodejs_server": {
    "url": "http://localhost:3000",
    "status": "connected",
    "data": {
      "status": "OK",
      "dataLoaded": true,
      "recordCount": 50
    }
  }
}
```

#### 📚 API Documentation
- **Swagger UI**: http://127.0.0.1:8000/docs
- **ReDoc**: http://127.0.0.1:8000/redoc

### Node.js Service (Port 3000)

#### 🔍 Search Wines
```http
POST /search?search_term=name&value=hennessy
```

#### 🏥 Health Check
```http
GET /health
```

## 🔍 Search Features

### Fuzzy Search Capabilities
- **Algorithm**: Fuse.js fuzzy string matching
- **Threshold**: Configurable accuracy (0.0 = exact, 1.0 = match anything)
- **Fields**: Searchable by name, brand, type, origin
- **Scoring**: Match confidence scoring (0-1, higher = better match)

### Search Examples

**Search by name:**
```bash
curl -X POST "http://localhost:8000/search?search_term=name&value=hennessy"
```

**Search by brand:**
```bash
curl -X POST "http://localhost:8000/search?search_term=brand&value=hennessy"
```

**Search by type:**
```bash
curl -X POST "http://localhost:8000/search?search_term=type&value=cognac"
```

## 🏛️ Architecture Patterns

### Node.js Service
- **Singleton Pattern**: Wine class ensures single instance
- **Promise-based async**: CSV loading and error handling
- **Middleware**: Express.js middleware for request processing

### FastAPI Service  
- **Proxy Pattern**: Forwards requests to Node.js service
- **Circuit Breaker**: Handles Node.js service unavailability
- **Schema Validation**: Pydantic models for type safety

## ⚙️ Configuration

### Node.js Environment Variables
```env
PORT=3000                    # Server port
CSV_FILE=wine_database.csv   # Data source file
SEARCH_THRESHOLD=0.3         # Default fuzzy search threshold
```

### FastAPI Configuration
```python
NODEJS_BASE_URL = "http://localhost:3000"  # Node.js service URL
```

## 🔧 Development

### Adding New Wine Records
1. Add records to `wine_database.csv`
2. Restart Node.js service to reload data

### Modifying Search Logic
- Edit `Nodejs/model/wine.js`
- Adjust Fuse.js options in `search()` method

### API Extensions
- Add endpoints in respective service files
- Update API documentation

## 🧪 Testing

### Health Check Tests
```bash
# Test FastAPI health
curl http://localhost:8000/health

# Test Node.js health  
curl http://localhost:3000/health
```

### Search Functionality Tests
```bash
# Test various search terms
curl -X POST "http://localhost:8000/search?search_term=name&value=hennessy"
curl -X POST "http://localhost:8000/search?search_term=brand&value=hennessy"
curl -X POST "http://localhost:8000/search?search_term=origin&value=france"
```

## 🐛 Troubleshooting

### Common Issues

**Node.js service not starting:**
- Check if port 3000 is available
- Verify wine_database.csv exists
- Check .env file configuration

**FastAPI cannot connect to Node.js:**
- Ensure Node.js service is running first
- Verify NODEJS_BASE_URL configuration
- Check firewall settings

**Empty search results:**
- Verify CSV data format
- Check search_term parameter spelling
- Adjust search threshold in .env file

### Debugging

Enable verbose logging:
```javascript
// In wine.js, add console.log statements
console.log("Search term:", search_term);
console.log("Search results:", results.length);
```

## 📝 API Response Examples

### Successful Search
```json
[
  {
    "name": "Hennessy Paradis Imperial",
    "brand": "Hennessy", 
    "type": "Cognac",
    "origin": "France",
    "price": 75000000,
    "year": 2023,
    "matched_score": 0.95
  }
]
```

### Error Responses
```json
{
  "error": "Missing required query parameters: 'search_term' and 'value'"
}
```

```json
{
  "error": "Cannot connect to Node.js server. Make sure it's running on port 3000."
}
```

## 🔗 Service URLs

- **FastAPI Service**: http://127.0.0.1:8000
- **Node.js Service**: http://localhost:3000  
- **API Documentation**: http://127.0.0.1:8000/docs
- **Health Monitoring**: http://127.0.0.1:8000/health

## 📋 TODO / Future Enhancements

- [ ] Add authentication/authorization
- [ ] Implement caching layer
- [ ] Add database persistence
- [ ] Create frontend interface
- [ ] Add unit tests
- [ ] Docker containerization
- [ ] Add logging middleware
- [ ] Performance monitoring

---

**Author**: GitHub Copilot  
**Version**: 1.0.0  
**Last Updated**: September 2025
