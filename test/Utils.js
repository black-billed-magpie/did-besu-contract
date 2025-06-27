const fs = require('fs');

function getLocalJson(path) {
    return JSON.parse(fs.readFileSync(path, 'utf8'));
}

module.exports = {
    getLocalJson: getLocalJson
}