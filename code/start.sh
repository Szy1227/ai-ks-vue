#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

if [ ! -d node_modules ]; then
  npm install 2>&1 | tee -a run.log
fi

npm run dev 2>&1 | tee -a run.log
