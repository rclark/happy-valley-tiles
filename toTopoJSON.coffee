fs = require "fs"
path = require "path"
topojson = require "topojson"

sourceDir = path.resolve "./geopolys"
destDir = path.resolve "./topojson"

toTopoJson = (geojson) ->
    options = 
        verbose: true
        "coordinate-system": "auto"
        quantization: 1e4
        "stich-poles": true
        "property-transform": (obj, key, val) ->
            obj[key] = val
            return true
    objects =
        features: geojson
    topojson.topology objects, options
    
fs.readdir sourceDir, (err, zs) ->
    zs.forEach (z) ->
        throw err if err?
        zSource = path.join sourceDir, z
        zDest = path.join destDir, z
        fs.mkdirSync zDest if not fs.existsSync zDest        
        fs.readdir zSource, (err, xs) ->
            throw err if err?
            xs.forEach (x) ->
                xSource = path.join zSource, x
                xDest = path.join zDest, x
                fs.mkdirSync xDest if not fs.existsSync xDest
                fs.readdir xSource, (err, files) ->
                    files.forEach (file) ->
                        y = path.basename file, ".geojson"
                        fileSource = path.join xSource, file
                        fileDest = path.join xDest, "#{y}.topojson"
                        data = fs.readFileSync fileSource
                        tjs = toTopoJson JSON.parse data
                        fs.writeFileSync fileDest, tjs
                        console.log "Created #{fileDest}"
                        