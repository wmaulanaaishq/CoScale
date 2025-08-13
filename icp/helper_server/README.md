# ICP Helper Server (Opsional)

Bridge HTTP -> `dfx canister call` untuk update, dijalankan di WSL (karena `dfx` tersedia di sana).

## Jalankan
```bash
cd /workspace/icp/helper_server
npm install
export CANISTER_ID=$(dfx canister id kawan_umkm_backend)
node index.js
# server di http://127.0.0.1:8000
```

## Gunakan di Agen
Set `ICP_HELPER_URL=http://127.0.0.1:8000` sebelum menjalankan `agent.py`.