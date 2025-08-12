# Kawan UMKM MVP

Komponen:
- Backend ICP (Motoko) di `kawan_umkm_backend`
- Agen AI (Python uAgents) di `agent`
- Frontend Next.js + Tailwind di `kawan_umkm_dashboard`

## Menjalankan Backend (ICP)
1. Pasang DFX SDK (lihat dokumentasi ICP).
2. Jalankan local replica: `dfx start --background`
3. Deploy: `cd kawan_umkm_backend && dfx deploy`
4. Catat `Canister Id` untuk `kawan_umkm_backend`.
5. Uji endpoint JSON (query): `curl "http://127.0.0.1:4943/?canisterId=<CANISTER_ID>&q=permintaan"`

## Menjalankan Agen (Python)
1. `cd agent && python3 -m venv .venv && source .venv/bin/activate`
2. `pip install -r requirements.txt`
3. Export env: `export CANISTER_ID=<CANISTER_ID> IC_HOST=http://127.0.0.1:4943`
4. Jalankan: `python agent.py`

## Menjalankan Frontend (Next.js)
1. `cd kawan_umkm_dashboard && npm install`
2. Salin `.env.local.example` ke `.env.local` dan isi `NEXT_PUBLIC_CANISTER_ID`.
3. `npm run dev` lalu buka `http://localhost:3000`

Alur kerja: Jalankan canister, jalankan agen, lihat data muncul di dashboard. Endpoint HTTP `/permintaan` dari canister tersedia untuk pembacaan JSON saja. Update state dilakukan via panggilan update `tambahPermintaan` oleh agen menggunakan `ic-py`.
