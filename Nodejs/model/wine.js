const fs = require("fs");
const csv = require("csv-parser");
const Fuse = require("fuse.js");

class Wine {
  constructor() {
    if (Wine.instance) {
      return Wine.instance;
    }

    this.dataset = [];
    this.keys = []; // store the dataset's attributes
    this.isLoaded = false;
    Wine.instance = this;
  }

  init(file_name = process.env.CSV_FILE) {
    return new Promise((resolve, reject) => {
      // Read csv file and push all rows into dataset
      fs.createReadStream(file_name)
        .pipe(csv())
        .on("data", (row) => {
          let _row = {
            ...row,
            year: parseInt(row.year) || row.year,
            price: parseInt(row.price) || row.price,
          };
          this.dataset.push(_row);
        })
        .on("end", () => {
          console.log("CSV file successfully loaded!");

          // Check if dataset is empty and get keys after loading is complete
          if (this.dataset.length === 0) {
            reject(new Error("Dataset is empty after loading CSV file."));
          } else {
            this.keys = Object.keys(this.dataset[0]); // Note: direct assignment, not push
            this.isLoaded = true;
            resolve();
          }
        })
        .on("error", (error) => {
          reject(new Error(`Error reading CSV file: ${error.message}`));
        });
    });
  }

  search(search_term = "name", value = "hennessy", threshold = 0.3) {
    let term;

    // find the matched attributes to the search_term
    this.keys.map((key) => {
      if (key === search_term) term = key;
    });

    if (!term) {
      throw new Error(
        `Search term "${search_term}" not found in dataset keys.`
      );
    }

    // special configuration for the "full_name" attribute
    if (term === "name") term = "full_name";
    // setup the search key and expected accuracy
    let options = {
      threshold: threshold, // error level
      includeScore: true,
      shouldSort: true,
      keys: [{ name: term, weight: 1 }],
    };

    let fuse = new Fuse(this.dataset, options);

    return fuse.search(value);
  }
}

module.exports = Wine;
