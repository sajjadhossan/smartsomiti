const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const versionJsonPath = path.join(rootDir, 'version.json');
const pubspecPath = path.join(rootDir, 'pubspec.yaml');
const packageJsonPath = path.join(rootDir, 'package.json');
const indexHtmlPath = path.join(rootDir, 'index.html');
const previewHtmlPath = path.join(rootDir, 'preview.html');

let versionData = { version: '2.5.1', buildNumber: 2 };
if (fs.existsSync(versionJsonPath)) {
  versionData = JSON.parse(fs.readFileSync(versionJsonPath, 'utf8'));
}

const arg = process.argv[2] || 'patch';
let parts = versionData.version.split('.').map(Number);
let buildNum = Number(versionData.buildNumber || 1) + 1;

if (arg === 'major') {
  parts[0] += 1;
  parts[1] = 0;
  parts[2] = 0;
} else if (arg === 'minor') {
  parts[1] += 1;
  parts[2] = 0;
} else if (arg === 'patch') {
  parts[2] += 1;
} else if (/^\d+\.\d+\.\d+$/.test(arg)) {
  parts = arg.split('.').map(Number);
}

const newVersion = parts.join('.');
versionData.version = newVersion;
versionData.buildNumber = buildNum;
versionData.releaseDate = new Date().toISOString().split('T')[0];

// 1. Update version.json
fs.writeFileSync(versionJsonPath, JSON.stringify(versionData, null, 2) + '\n');
console.log(`✓ Updated version.json -> v${newVersion} (Build ${buildNum})`);

// 2. Update package.json
if (fs.existsSync(packageJsonPath)) {
  const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  pkg.version = newVersion;
  fs.writeFileSync(packageJsonPath, JSON.stringify(pkg, null, 2) + '\n');
  console.log(`✓ Updated package.json -> v${newVersion}`);
}

// 3. Update pubspec.yaml
if (fs.existsSync(pubspecPath)) {
  let pubspec = fs.readFileSync(pubspecPath, 'utf8');
  pubspec = pubspec.replace(/^version:\s*.*$/m, `version: ${newVersion}+${buildNum}`);
  fs.writeFileSync(pubspecPath, pubspec);
  console.log(`✓ Updated pubspec.yaml -> ${newVersion}+${buildNum}`);
}

// 4. Update index.html & preview.html
function updateHtmlFile(filePath, fileName) {
  if (!fs.existsSync(filePath)) return;
  let html = fs.readFileSync(filePath, 'utf8');
  // Replace any existing vX.Y.Z with newVersion
  html = html.replace(/v\d+\.\d+\.\d+/g, `v${newVersion}`);
  fs.writeFileSync(filePath, html);
  console.log(`✓ Updated ${fileName} version badges -> v${newVersion}`);
}

const assetsHtmlPath = path.join(rootDir, 'assets', 'index.html');
updateHtmlFile(indexHtmlPath, 'index.html');
updateHtmlFile(assetsHtmlPath, 'assets/index.html');
updateHtmlFile(previewHtmlPath, 'preview.html');

console.log(`\n🎉 All files synchronized to version v${newVersion} (Build ${buildNum})!`);
