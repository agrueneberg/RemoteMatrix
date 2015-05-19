#!/usr/bin/env node

var fs, csv, http, url, path, parser;

fs = require("fs");
csv = require("csv-parse");
http = require("http");
url = require("url");

path = process.argv[2];

parser = csv({
    auto_parse: true
}, function (err, matrix) {

    var matrix, toZeroIndex;

    if (err) {
        console.error("Could not open", path);
        process.exit(1);
    }

    toZeroIndex = function (x) {
        return x - 1;
    };

    http.createServer(function (req, res) {
        var indexes, parsedUrl, response, subset;
        indexes = {};
        parsedUrl = url.parse(req.url, true);
        if (parsedUrl.path === "/dim") {
            response = {
                rows: matrix.length,
                columns: matrix[0].length
            };
        } else {
            ["i", "j"].forEach(function (index) {
                if (parsedUrl.query.hasOwnProperty(index)) {
                    indexes[index] = parsedUrl.query[index].split(",").map(toZeroIndex);
                }
            });
            if (indexes.i !== undefined && indexes.j !== undefined) {
                subset = matrix.map(function (row) {
                    return row.filter(function (col, idx) {
                        return indexes.j.indexOf(idx) !== -1;
                    });
                }).filter(function (col, idx) {
                    return indexes.i.indexOf(idx) !== -1;
                });
            } else if (indexes.i !== undefined && indexes.j === undefined) {
                subset = matrix.filter(function (row, idx) {
                    return indexes.i.indexOf(idx) !== -1;
                });
            } else if (indexes.i === undefined && indexes.j !== undefined) {
                subset = matrix.map(function (row) {
                    return row.filter(function (col, idx) {
                        return indexes.j.indexOf(idx) !== -1;
                    });
                });
            } else {
                subset = matrix;
            }
            response = subset;
        }
        res.writeHead(200, {
            "Content-Type": "application/json"
        });
        res.end(JSON.stringify(response));
    }).listen(5000, "127.0.0.1");

    console.log("Server running at http://127.0.0.1:5000/");

});

fs.createReadStream(path).pipe(parser);

