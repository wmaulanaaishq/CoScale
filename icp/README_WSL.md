# Kawan UMKM Backend (ICP) - Instruksi WSL

Ikuti langkah ini di dalam WSL (Ubuntu) agar `dfx` tersedia:

## 1) Instal DFX (sekali saja)
```bash
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
# kemudian tambahkan ke PATH (restart shell jika perlu)
source "$HOME/.local/share/dfx/env"

dfx --version
```

## 2) Jalankan jaringan lokal IC dan deploy canister
```bash
cd /workspace/icp

# start local replica
dfx start --background

# deploy canisters
dfx deploy
```

Setelah deploy, Anda akan melihat `Canister ID` untuk `kawan_umkm_backend`. Simpan ID tersebut untuk digunakan di agen Python dan frontend.

## 3) Memanggil metode canister
- Query semua permintaan:
```bash
dfx canister call kawan_umkm_backend getPermintaan '()'
```

- Tambah / update permintaan (contoh):
```bash
dfx canister call kawan_umkm_backend tambahPermintaan '(
  record {
    id = 1 : nat;
    namaBarang = "Beras Pandan Wangi";
    totalKuantitas = 225 : nat;
    unit = "kg";
    jumlahPartisipan = 3 : nat;
    status = "MENGUMPULKAN"
  }
)'
```

- Reset data:
```bash
dfx canister call kawan_umkm_backend resetData '()'
```

## 4) Interface Candid
Setelah deploy, file candid akan tersedia:
- `./.dfx/local/canisters/kawan_umkm_backend/kawan_umkm_backend.did`

Contoh isi (dari definisi di Motoko):
```
service : {
  getPermintaan : () -> (vec record {
    id : nat; namaBarang : text; totalKuantitas : nat; unit : text; jumlahPartisipan : nat; status : text
  }) query;
  tambahPermintaan : (record {
    id : nat; namaBarang : text; totalKuantitas : nat; unit : text; jumlahPartisipan : nat; status : text
  }) -> ();
  resetData : () -> ();
}
```

## 5) Dapatkan CANISTER_ID
```bash
echo $(dfx canister id kawan_umkm_backend)
```

Gunakan nilai ini sebagai `CANISTER_ID` untuk agen Python dan frontend.