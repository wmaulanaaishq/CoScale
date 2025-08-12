#!/usr/bin/env bash
set -euo pipefail

# Usage: ./run_dashboard.sh [CANISTER_ID] [IC_HOST]
# If CANISTER_ID provided, it will be inserted into .env.local

CANISTER_ID=${1:-${CANISTER_ID:-}}
IC_HOST=${2:-${IC_HOST:-http://127.0.0.1:4943}}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."
FE_DIR="${PROJECT_ROOT}/kawan_umkm_dashboard"

cd "$FE_DIR"

# Prepare env
cp -n .env.local.example .env.local 2>/dev/null || true

if [ -n "$CANISTER_ID" ]; then
  if grep -q '^NEXT_PUBLIC_CANISTER_ID=' .env.local; then
    sed -i "s|^NEXT_PUBLIC_CANISTER_ID=.*|NEXT_PUBLIC_CANISTER_ID=${CANISTER_ID}|" .env.local
  else
    echo "NEXT_PUBLIC_CANISTER_ID=${CANISTER_ID}" >> .env.local
  fi
fi

if grep -q '^NEXT_PUBLIC_IC_HOST=' .env.local; then
  sed -i "s|^NEXT_PUBLIC_IC_HOST=.*|NEXT_PUBLIC_IC_HOST=${IC_HOST}|" .env.local
else
  echo "NEXT_PUBLIC_IC_HOST=${IC_HOST}" >> .env.local
fi

# Install and run
if command -v npm >/dev/null 2>&1; then
  npm install
  npm run dev
else
  echo "npm tidak ditemukan. Install Node.js/NPM di WSL."
  exit 1
fi