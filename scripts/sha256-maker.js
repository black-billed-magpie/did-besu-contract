const { createHash } = require("crypto");

function getSha256Hash(data) {
  return createHash('sha256').update(data).digest('hex');
}

// 명령줄 인수 처리
const args = process.argv.slice(2);
if (args.length !== 1) {
  console.error("Usage: node sha256Maker.js <data>");
  process.exit(1);
}

const data = args[0];
const hash = getSha256Hash(data);
console.log(`SHA-256 hash of "${data}": ${hash}`);