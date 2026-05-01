#!/usr/bin/env node

const { CircomRunner, bindings } = require("circom2");
const fs = require("fs");
const path = require("path");

function isPathArg(value) {
  return !value.startsWith("-");
}

function commonParent(paths) {
  if (paths.length === 0) {
    return process.cwd();
  }

  const [first, ...rest] = paths.map((value) => path.resolve(value).split(path.sep));
  let length = first.length;
  for (const parts of rest) {
    length = Math.min(length, parts.length);
    for (let index = 0; index < length; index += 1) {
      if (parts[index].toLowerCase() !== first[index].toLowerCase()) {
        length = index;
        break;
      }
    }
  }
  return first.slice(0, length).join(path.sep) || path.parse(process.cwd()).root;
}

function wasiArg(value) {
  if (value.startsWith("-")) {
    return value;
  }
  return path.relative(process.cwd(), path.resolve(value)).split(path.sep).join("/");
}

function preopensFull() {
  const preopens = {};
  let cwd = process.cwd();
  while (true) {
    const relative = path.relative(process.cwd(), cwd) || ".";
    const wasiPath = relative.split(path.sep).join("/");
    preopens[wasiPath] = relative;

    const next = path.dirname(cwd);
    if (next === cwd) {
      break;
    }
    cwd = next;
  }
  return preopens;
}

async function main() {
  const rawArgs = process.argv.slice(2);
  const root = commonParent(rawArgs.filter(isPathArg));
  process.chdir(root);

  const args = rawArgs.map(wasiArg);
  if (args.length === 0) {
    args.push("--help");
  }

  const circom = new CircomRunner({
    args,
    env: process.env,
    preopens: preopensFull(),
    bindings: {
      ...bindings,
      exit(code) {
        process.exit(code);
      },
      kill(signal) {
        process.kill(process.pid, signal);
      },
      fs,
    },
  });

  const wasmBytes = fs.readFileSync(require.resolve("circom2/circom.wasm"));
  await circom.execute(wasmBytes);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
