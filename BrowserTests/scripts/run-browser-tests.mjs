#!/usr/bin/env node

// Builds the browser test app via `vite build`, serves it with `vite preview`, then
// measures rendered geometry in Chromium and compares it against what each modifier is
// supposed to mean.
//
// This exists because TestDOM records the CSS we emit, not what a browser resolves it
// to. `transform: rotate(45deg)` is a valid string in both namespaces and means two
// different things, so only a real engine can tell us whether a modifier is correct.
//
// Usage: node scripts/run-browser-tests.mjs

import { spawn, spawnSync } from "node:child_process";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import puppeteer from "puppeteer";

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(__dirname, "..");

const PREVIEW_PORT = 4174;
const PREVIEW_URL = `http://localhost:${PREVIEW_PORT}`;
const TOLERANCE = 0.75;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// A 40x40 rect at (20,20) in a 1:1 viewBox, so its untransformed centre is (40,40).
const R2 = 40 * Math.SQRT2; // bounding box of that rect rotated 45 degrees

const expectations = [
  { id: "plain", cx: 40, cy: 40, w: 40, h: 40, note: "untransformed baseline" },
  { id: "rotated", cx: 40, cy: 40, w: R2, h: R2, note: "45deg about its own centre" },
  { id: "rotatedTopLeading", cx: 20, cy: 20 + 20 * Math.SQRT2, w: R2, h: R2, note: "45deg about its top-left" },
  { id: "scaled", cx: 40, cy: 40, w: 80, h: 80, note: "2x about its own centre" },
  { id: "scaledXY", cx: 40, cy: 40, w: 80, h: 40, note: "2x horizontally only" },
  { id: "offset", cx: 50, cy: 45, w: 40, h: 40, note: "absolute pixel translation" },
  { id: "group", cx: 40, cy: 40, w: R2, h: R2, note: "45deg on a container" },
];

function build() {
  console.error("Building browser test app...");
  const result = spawnSync(resolve(projectRoot, "node_modules/.bin/vite"), ["build"], {
    cwd: projectRoot,
    encoding: "utf-8",
    timeout: 600_000,
    stdio: ["ignore", "pipe", "pipe"],
  });
  if (result.status !== 0) {
    throw new Error(`vite build failed:\n${result.stdout}\n${result.stderr}`);
  }
  console.error("Build complete.");
}

function startPreview() {
  return new Promise((res, rej) => {
    const proc = spawn(
      "node_modules/.bin/vite",
      ["preview", "--port", String(PREVIEW_PORT), "--strictPort"],
      { cwd: projectRoot, stdio: ["ignore", "pipe", "pipe"] },
    );

    let settled = false;
    const fail = (err) => {
      if (!settled) { settled = true; rej(err); }
    };
    proc.on("error", fail);
    proc.on("exit", (code) => fail(new Error(`Preview server exited with code ${code}`)));

    (async () => {
      const startedAt = Date.now();
      while (!settled && Date.now() - startedAt < 60_000) {
        try {
          const response = await fetch(PREVIEW_URL, { method: "GET" });
          if (response.ok) { settled = true; res(proc); return; }
        } catch {
          // not up yet
        }
        await sleep(250);
      }
      fail(new Error("Preview server did not start within 60s"));
    })();
  });
}

async function measure(page) {
  return page.evaluate((ids) => {
    const canvas = document.getElementById("canvas").getBoundingClientRect();
    const out = {};
    for (const id of ids) {
      const el = document.getElementById(id);
      if (!el) { out[id] = null; continue; }
      const r = el.getBoundingClientRect();
      out[id] = {
        cx: r.x - canvas.x + r.width / 2,
        cy: r.y - canvas.y + r.height / 2,
        w: r.width,
        h: r.height,
      };
    }
    return out;
  }, expectations.map((e) => e.id));
}

function compare(actual) {
  const failures = [];
  const fmt = (n) => n.toFixed(2).padStart(7);

  console.error("");
  console.error("  SVG transform geometry");
  console.error("");
  console.error(`  ${"case".padEnd(18)} ${"centre".padStart(17)} ${"size".padStart(17)}`);
  console.error(`  ${"─".repeat(18)} ${"─".repeat(17)} ${"─".repeat(17)}`);

  for (const e of expectations) {
    const a = actual[e.id];
    if (!a) {
      failures.push(`${e.id}: element not found in the rendered page`);
      continue;
    }
    const off = ["cx", "cy", "w", "h"].filter((k) => Math.abs(a[k] - e[k]) > TOLERANCE);
    const mark = off.length === 0 ? "✔" : "✘";
    console.error(
      `${mark} ${e.id.padEnd(18)} (${fmt(a.cx)},${fmt(a.cy)}) ${fmt(a.w)}x${fmt(a.h)}   ${e.note}`,
    );
    if (off.length > 0) {
      console.error(
        `  ${"".padEnd(18)} expected (${fmt(e.cx)},${fmt(e.cy)}) ${fmt(e.w)}x${fmt(e.h)}`,
      );
      failures.push(`${e.id}: ${off.join(", ")} outside ${TOLERANCE}px of expected`);
    }
  }
  console.error("");
  return failures;
}

build();
console.error("Starting preview server...");
const previewProc = await startPreview();
console.error(`Preview server running on ${PREVIEW_URL}`);

let failures = [];
try {
  const browser = await puppeteer.launch({ headless: true, args: ["--no-sandbox"] });
  try {
    const page = await browser.newPage();
    await page.goto(PREVIEW_URL, { waitUntil: "networkidle0" });
    await page.waitForSelector("#app[data-ready='true']", { timeout: 30_000 });
    await page.waitForSelector("#canvas", { timeout: 30_000 });
    failures = compare(await measure(page));
  } finally {
    await browser.close();
  }
} finally {
  previewProc.kill();
}

if (failures.length > 0) {
  console.error(`${failures.length} failure(s):`);
  for (const f of failures) console.error(`  - ${f}`);
  process.exit(1);
}

console.error("All geometry matches.");
