# Agen AI (Fetch.ai uAgents)

## Setup
```bash
cd /workspace/agent
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Konfigurasi
Setel `CANISTER_ID` dari hasil deploy di WSL.
```
export CANISTER_ID=<isi_dari_wsl>
# Opsional jika ada helper HTTP: export ICP_HELPER_URL=http://localhost:8000
```

## Jalankan Agen
```bash
python agent.py
```
Agen akan berjalan setiap 60 detik:
- Mengagregasi data dari `data_simulasi.py`.
- Mencetak perintah `dfx canister call ...` yang bisa Anda jalankan di WSL untuk mengirim data ke ICP.
- Jika `ICP_HELPER_URL` diset, agen akan mencoba POST ke helper tersebut.

## Integrasi dengan ICP
Cara tercepat: copy perintah yang dicetak agen dan jalankan dari terminal WSL yang telah men-setup dfx (lihat `/workspace/icp/README_WSL.md`).