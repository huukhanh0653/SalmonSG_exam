#!/bin/bash

echo "Starting Wine Search Services..."
echo "================================"

# Start Node.js server in background
echo "Starting Node.js server on port 3000..."
cd ../Nodejs
start "Node.js Server" cmd /k "node index.js"

# Wait a bit for Node.js to start
timeout /t 3

# Start FastAPI server
echo "Starting FastAPI proxy server on port 8000..."
cd ../FastAPI
python -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload