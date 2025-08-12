#!/usr/bin/env bash
set -euo pipefail

# Jalankan dari WSL: script ini akan start replica, deploy, dan menampilkan CANISTER_ID + candid

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."
BACKEND_DIR="${PROJECT_ROOT}/kawan_umkm_backend"

cd "$BACKEND_DIR"

# Pastikan dfx tersedia
command -v dfx >/dev/null 2>&1 || { echo "dfx tidak ditemukan. Install dulu di WSL: sh -ci \"$(curl -fsSL https://internetcomputer.org/install.sh)\""; exit 1; }

# Stop jika ada replica lama, lalu start baru
set +e
(dfX stop) >/dev/null 2>&1
set -e

dfx start --background

echo "Deploying canisters..."
dfx deploy

CID=$(dfx canister id kawan_umkm_backend)

echo ""
echo "=== Deploy selesai ==="
echo "CANISTER_ID=${CID}"

echo ""
echo "=== Candid Interface ==="
dfx canister call kawan_umkm_backend __get_candid_interface_tmp_hack '()' | sed 's/\\n/\n/g' | sed 's/\\"/"/g' || true

echo ""
echo "=== Test HTTP JSON (permintaan) ==="
HTTP_URL="http://127.0.0.1:4943/?canisterId=${CID}&q=permintaan"
echo "$HTTP_URL"
curl -s "$HTTP_URL" || true