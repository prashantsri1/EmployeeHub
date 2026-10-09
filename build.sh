#!/usr/bin/env bash
# Netlify build script: installs the Flutter SDK (not preinstalled on Netlify) and builds the web app.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.7}"
FLUTTER_ROOT_DIR="${FLUTTER_ROOT_DIR:-$HOME/flutter-sdk}"
FLUTTER_DIR="$FLUTTER_ROOT_DIR/flutter"
RELEASES_URL="https://storage.googleapis.com/flutter_infra_release/releases"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  mkdir -p "$FLUTTER_ROOT_DIR"
  curl -fsSL "$RELEASES_URL/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ -C "$FLUTTER_ROOT_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"

# First run downloads the Dart SDK and builds the flutter tool.
flutter config --enable-web --no-analytics >/dev/null

# Flutter normally derives its version from git, which can fail in restricted
# environments (reporting 0.0.0-unknown and breaking dependency resolution).
# Write the version cache from the official release metadata instead.
curl -fsSL "$RELEASES_URL/releases_linux.json" -o "$FLUTTER_DIR/bin/cache/releases_linux.json"
FLUTTER_DIR="$FLUTTER_DIR" FLUTTER_VERSION="$FLUTTER_VERSION" node -e '
  const fs = require("fs");
  const path = require("path");
  const root = process.env.FLUTTER_DIR;
  const version = process.env.FLUTTER_VERSION;
  const cache = path.join(root, "bin", "cache");
  const releases = JSON.parse(fs.readFileSync(path.join(cache, "releases_linux.json"), "utf8")).releases;
  const r = releases.find((x) => x.version === version && x.channel === "stable");
  if (!r) throw new Error(`Flutter ${version} not found in stable release metadata`);
  const read = (f) => (fs.existsSync(f) ? fs.readFileSync(f, "utf8").trim() : null);
  const engine = read(path.join(root, "bin", "internal", "engine.version")) || read(path.join(cache, "engine.stamp"));
  const devtools = read(path.join(cache, "dart-sdk", "bin", "resources", "devtools", "version.json"));
  fs.writeFileSync(path.join(cache, "flutter.version.json"), JSON.stringify({
    frameworkVersion: r.version,
    channel: "stable",
    repositoryUrl: "https://github.com/flutter/flutter.git",
    frameworkRevision: r.hash,
    frameworkCommitDate: r.release_date,
    engineRevision: engine,
    dartSdkVersion: r.dart_sdk_version,
    devToolsVersion: devtools ? JSON.parse(devtools).version || "unknown" : "unknown",
    flutterVersion: r.version,
  }, null, 2));
'

flutter --version
flutter pub get
flutter build web --release
