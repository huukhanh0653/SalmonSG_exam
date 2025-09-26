const express = require("express");
const fs = require("fs");
const csv = require("csv-parser");
const Fuse = require("fuse.js");
const Wine = require("./model/wine.js");
const app = express();
require("dotenv").config();

// import the singleton class Wine
const wineInstance = new Wine();

// Initialize the wine data asynchronously
const initializeWineData = async () => {
    try {
        console.log("Starting wine data initialization...");
        console.log("CSV_FILE from env:", process.env.CSV_FILE);
        console.log("PORT from env:", process.env.PORT);
        
        await wineInstance.init();
        console.log("Wine data initialized successfully!");
        return true;
    } catch (error) {
        console.error("Failed to initialize wine data:", error.message);
        console.error("Full error:", error);
        return false;
    }
};

// Initialize wine data before starting the server
initializeWineData().then((success) => {
    if (!success) {
        console.log("Server starting anyway with empty dataset...");
    }
    
    // Endpoint API fuzzy search
    app.post("/search", (req, res) => {
        const { search_term, value } = req.query;
        
        if (!search_term || !value) {
            return res.status(400).json({ 
                error: "Missing required query parameters: 'search_term' and 'value'" 
            });
        }

        try {
            if (!wineInstance.isLoaded) {
                return res.status(503).json({ 
                    error: "Wine data not loaded yet. Please try again later." 
                });
            }
            
            let temp = wineInstance.search(search_term, value);

            let result = temp.map(item => ({
                name: item.item.full_name,
                brand: item.item.brand,
                origin: item.item.origin,
                price: item.item.price,
                year: item.item.year,
                matched_score: Math.round((1-item.score)*100 * 100) / 100
            }));
            
            res.json(result);
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    });

    // Health check endpoint
    app.get("/health", (req, res) => {
        res.json({
            status: "OK",
            dataLoaded: wineInstance.isLoaded,
            recordCount: wineInstance.dataset ? wineInstance.dataset.length : 0,
            availableKeys: wineInstance.keys || []
        });
    });

    const PORT = process.env.PORT || 3000;
    
    app.listen(PORT, () => {
        console.log(`Server is running at http://localhost:${PORT}`);
        console.log(`Health check: http://localhost:${PORT}/health`);
        console.log(`Search endpoint: http://localhost:${PORT}/search?term=<field>&value=<search_value>`);
    });
}).catch((error) => {
    console.error("Unexpected error:", error);
});