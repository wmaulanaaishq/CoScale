# Kawan UMKM Dashboard

## Setup
```bash
cd /workspace/kawan_umkm_dashboard
npm install
npm run dev
```

Pastikan backend ICP berjalan di WSL dan `CANISTER_ID` sudah diketahui.

## Konfigurasi
Buat file `.env.local`:
```
NEXT_PUBLIC_CANISTER_ID=<isi_dari_wsl>
NEXT_PUBLIC_ICP_HTTP="http://127.0.0.1:4943"
REFRESH_MS=30000
```

## Menjalankan
```bash
npm run dev
# buka http://localhost:3000
```