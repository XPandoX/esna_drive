const fs = require('fs');
const path = require('path');

function getFiles(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    file = path.join(dir, file);
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) {
      results = results.concat(getFiles(file));
    } else if (file.endsWith('.dart')) {
      results.push(file);
    }
  });
  return results;
}

const files = getFiles(path.join(__dirname, '../lib'));
console.log('Total Dart files found:', files.length);

let errors = 0;
files.forEach(f => {
  const content = fs.readFileSync(f, 'utf8');
  // Check relative imports
  const importRegex = /import\s+['"](\.\.?\/[^'"]+)['"];/g;
  let match;
  while ((match = importRegex.exec(content)) !== null) {
    const rel = match[1];
    const resolved = path.resolve(path.dirname(f), rel);
    if (!fs.existsSync(resolved)) {
      console.error('BROKEN IMPORT in ' + f + ': ' + rel + ' -> ' + resolved);
      errors++;
    }
  }

  // Token balances
  let brace = 0, paren = 0, bracket = 0;
  let inString = false, stringChar = '', inLineComment = false, inBlockComment = false;
  for (let i = 0; i < content.length; i++) {
    const c = content[i];
    const next = content[i+1];
    if (inLineComment) {
      if (c === '\n') inLineComment = false;
      continue;
    }
    if (inBlockComment) {
      if (c === '*' && next === '/') { inBlockComment = false; i++; }
      continue;
    }
    if (inString) {
      if (c === '\\') { i++; continue; }
      if (c === stringChar) { inString = false; }
      continue;
    }
    if (c === '/' && next === '/') { inLineComment = true; i++; continue; }
    if (c === '/' && next === '*') { inBlockComment = true; i++; continue; }
    if (c === '"' || c === "'") { inString = true; stringChar = c; continue; }

    if (c === '{') brace++;
    if (c === '}') brace--;
    if (c === '(') paren++;
    if (c === ')') paren--;
    if (c === '[') bracket++;
    if (c === ']') bracket--;
  }

  if (brace !== 0 || paren !== 0 || bracket !== 0) {
    console.error('UNBALANCED TOKENS in ' + f + ': brace=' + brace + ', paren=' + paren + ', bracket=' + bracket);
    errors++;
  }
});

if (errors === 0) {
  console.log('SUCCESS: All Dart files have 0 broken imports and balanced structure!');
} else {
  console.log('FAILED with ' + errors + ' errors');
}
