from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
import httpx
import asyncio
from typing import Optional

# Create FastAPI instance
app = FastAPI(
    title="Wine Search Proxy API",
    description="FastAPI proxy that forwards requests to Node.js wine search service",
    version="1.0.0"
)

# Configuration
NODEJS_BASE_URL = "http://localhost:3000"

# Pydantic models
class SearchRequest(BaseModel):
    search_term: str
    value: str

class WineResponse(BaseModel):
    name: str
    brand: str
    type: str
    origin: str
    price: int
    year: int
    match_score: float

@app.get("/")
async def root():
    return {
        "message": "Wine Search Proxy API", 
        "status": "running",
        "proxy_target": NODEJS_BASE_URL
    }

@app.post("/search")
async def search_wines(
    search_term: str = Query(..., description="Field to search in (e.g., 'name', 'brand')"),
    value: str = Query(..., description="Value to search for")
):
    """
    Proxy endpoint that forwards search requests to Node.js server
    """
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            # Make request to Node.js server
            response = await client.post(
                f"{NODEJS_BASE_URL}/search",
                params={
                    "search_term": search_term,
                    "value": value
                }
            )
            
            # Check if Node.js server responded successfully
            if response.status_code == 200:
                return response.json()
            else:
                # Forward the error from Node.js
                raise HTTPException(
                    status_code=response.status_code,
                    detail=response.json() if response.content else "Error from Node.js server"
                )
                
    except httpx.ConnectError:
        raise HTTPException(
            status_code=503,
            detail="Cannot connect to Node.js server. Make sure it's running on port 3000."
        )
    except httpx.TimeoutException:
        raise HTTPException(
            status_code=504,
            detail="Node.js server timeout"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Proxy error: {str(e)}"
        )

@app.get("/health")
async def health_check():
    """
    Health check that also verifies Node.js server connectivity
    """
    nodejs_status = "unknown"
    
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(f"{NODEJS_BASE_URL}/health")
            if response.status_code == 200:
                nodejs_status = "connected"
                nodejs_data = response.json()
            else:
                nodejs_status = "error"
                nodejs_data = None
    except:
        nodejs_status = "disconnected"
        nodejs_data = None
    
    return {
        "status": "OK",
        "service": "Wine Search Proxy API",
        "version": "1.0.0",
        "nodejs_server": {
            "url": NODEJS_BASE_URL,
            "status": nodejs_status,
            "data": nodejs_data
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)