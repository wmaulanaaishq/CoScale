# Kawan UMKM - Cara Menjalankan MVP

## 1) Backend ICP (jalankan di WSL)
Lihat `icp/README_WSL.md`.
Ringkas:
```bash
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
source "$HOME/.local/share/dfx/env"

cd /workspace/icp
dfx start --background
dfx deploy
CANISTER_ID=$(dfx canister id kawan_umkm_backend)
echo $CANISTER_ID
```
Simpan `CANISTER_ID`.

## 2) Agen AI (jalankan di host ini)
```bash
cd /workspace/agent
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export CANISTER_ID=<dari_wsl>
python agent.py
```
Agen akan mencetak perintah `dfx canister call ...` yang bisa dijalankan di WSL untuk mengirim data.

Opsional: Jika Anda memiliki helper HTTP untuk menjembatani, set `ICP_HELPER_URL`.

## 3) Frontend Next.js (jalankan di host ini)
```bash
cd /workspace/kawan_umkm_dashboard
npm install
# buat .env.local
cat > .env.local <<EOF
NEXT_PUBLIC_CANISTER_ID=<dari_wsl>
NEXT_PUBLIC_ICP_HTTP=http://127.0.0.1:4943
REFRESH_MS=30000
EOF

npm run dev
# buka http://localhost:3000
```

## Alur Demo
1. Jalankan canister ICP (WSL) dan dapatkan `CANISTER_ID`.
2. Jalankan agen Python (host), copy perintah `dfx canister call ...` dan jalankan di WSL untuk mengisi data, atau siapkan helper HTTP.
3. Buka dashboard; data akan termuat dari canister dan refresh setiap 30 detik.