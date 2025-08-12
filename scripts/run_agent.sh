#!/usr/bin/env bash
set -euo pipefail

# Usage: ./run_agent.sh <CANISTER_ID> [IC_HOST]
# Default IC_HOST: http://127.0.0.1:4943

CANISTER_ID=${1:-${CANISTER_ID:-}}
IC_HOST=${2:-${IC_HOST:-http://127.0.0.1:4943}}

if [ -z "$CANISTER_ID" ]; then
  echo "CANISTER_ID belum diberikan. Usage: ./run_agent.sh <CANISTER_ID> [IC_HOST]"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."
AGENT_DIR="${PROJECT_ROOT}/agent"

cd "$AGENT_DIR"

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

export CANISTER_ID="$CANISTER_ID"
export IC_HOST="$IC_HOST"

python agent.py