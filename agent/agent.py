import os
import time
import hashlib
from collections import defaultdict
from typing import Dict, Any, List

from uagents import Agent

try:
    # Optional import of ic-py; we will guard runtime if not installed
    from ic.client import Client
    from ic.identity import Identity
    from ic.agent import Agent as IcAgent
    from ic.candid import Types, encode
except Exception:
    Client = None  # type: ignore
    Identity = None  # type: ignore
    IcAgent = None  # type: ignore
    Types = None  # type: ignore
    encode = None  # type: ignore

from data_simulasi import DATA_SIMULASI

CANISTER_ID = os.getenv("CANISTER_ID", "")
IC_HOST = os.getenv("IC_HOST", "http://127.0.0.1:4943")

agen = Agent(name="AgenAgregator", seed="AgenAgregator-Seed")


def group_permintaan(data: List[Dict[str, Any]]):
    groups: Dict[str, Dict[str, Any]] = {}
    for item in data:
        nama_barang = item["barang"]
        unit = item["unit"]
        kuantitas = int(item["kuantitas"])  # normalize
        if nama_barang not in groups:
            groups[nama_barang] = {
                "namaBarang": nama_barang,
                "unit": unit,
                "totalKuantitas": 0,
                "jumlahPartisipan": 0,
            }
        groups[nama_barang]["totalKuantitas"] += kuantitas
        groups[nama_barang]["jumlahPartisipan"] += 1
    return list(groups.values())


def compute_id(nama_barang: str) -> int:
    digest = hashlib.sha256(nama_barang.encode("utf-8")).digest()
    return int.from_bytes(digest[:8], byteorder="big", signed=False)


def kirim_ke_icp(permintaan: Dict[str, Any]):
    if not CANISTER_ID:
        print("[Agen] CANISTER_ID belum di-set. Lewati pengiriman.")
        return
    if Client is None:
        print("[Agen] ic-py belum terpasang. Tambahkan ke environment atau gunakan 'pip install -r requirements.txt'.")
        return
    try:
        client = Client(url=IC_HOST)
        identity = Identity()
        agent = IcAgent(identity, client)
        # gunakan root key untuk local replica
        try:
            agent.fetch_root_key()
        except Exception:
            pass
        record_type = Types.Record({
            "id": Types.Nat,
            "namaBarang": Types.Text,
            "totalKuantitas": Types.Nat,
            "unit": Types.Text,
            "jumlahPartisipan": Types.Nat,
            "status": Types.Text,
        })
        arg = encode([record_type], [{
            "id": int(permintaan["id"]),
            "namaBarang": str(permintaan["namaBarang"]),
            "totalKuantitas": int(permintaan["totalKuantitas"]),
            "unit": str(permintaan["unit"]),
            "jumlahPartisipan": int(permintaan["jumlahPartisipan"]),
            "status": str(permintaan.get("status", "MENGUMPULKAN")),
        }])
        res = agent.update_raw(CANISTER_ID, "tambahPermintaan", arg)
        print(f"[Agen] Dikirim ke ICP: {permintaan['namaBarang']} (bytes={len(arg)}) -> ok")
        return res
    except Exception as e:
        print(f"[Agen] Gagal mengirim ke ICP: {e}")


@agen.on_interval(period=60.0)
async def interval_task(ctx):
    ctx.logger.info("Menjalankan agregasi permintaan dari data simulasi...")
    groups = group_permintaan(DATA_SIMULASI)
    for g in groups:
        g["id"] = compute_id(g["namaBarang"])  # deterministik
        g.setdefault("status", "MENGUMPULKAN")
        kirim_ke_icp(g)


if __name__ == "__main__":
    print("Menjalankan AgenAgregator. Tekan Ctrl+C untuk berhenti.")
    try:
        agen.run()
    except KeyboardInterrupt:
        print("Dihentikan oleh pengguna.")