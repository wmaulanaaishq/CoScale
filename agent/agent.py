import os
import hashlib
from typing import Dict, Any, List, Tuple

from uagents import Agent

try:
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
    groups: Dict[Tuple[str, str], Dict[str, Any]] = {}
    for item in data:
        nama_barang = item["barang"]
        lokasi = item.get("lokasi", "")
        unit = item["unit"]
        kuantitas = int(item["kuantitas"])  # normalize
        key = (nama_barang, lokasi)
        if key not in groups:
            groups[key] = {
                "namaBarang": nama_barang,
                "lokasi": lokasi,
                "unit": unit,
                "totalKuantitas": 0,
                "jumlahPartisipan": 0,
            }
        groups[key]["totalKuantitas"] += kuantitas
        groups[key]["jumlahPartisipan"] += 1
    return list(groups.values())


def compute_id(key: str) -> int:
    digest = hashlib.sha256(key.encode("utf-8")).digest()
    return int.from_bytes(digest[:8], byteorder="big", signed=False)


def ic_agent():
    if Client is None:
        raise RuntimeError("ic-py belum terpasang")
    client = Client(url=IC_HOST)
    identity = Identity()
    agent = IcAgent(identity, client)
    try:
        agent.fetch_root_key()
    except Exception:
        pass
    return agent


def candid_record_arg(record_def: Dict[str, Any], value: Dict[str, Any]):
    return encode([Types.Record(record_def)], [value])


def call_update(method: str, arg_bytes: bytes):
    agent = ic_agent()
    return agent.update_raw(CANISTER_ID, method, arg_bytes)


def tambah_permintaan(permintaan: Dict[str, Any]):
    record_def = {
        "id": Types.Nat,
        "namaBarang": Types.Text,
        "totalKuantitas": Types.Nat,
        "unit": Types.Text,
        "jumlahPartisipan": Types.Nat,
        "status": Types.Text,
    }
    arg = candid_record_arg(record_def, permintaan)
    call_update("tambahPermintaan", arg)


def tambah_notifikasi(pesan: str):
    arg = encode([Types.Text], [pesan])
    call_update("tambahNotifikasi", arg)


def create_escrow(permintaan_id: int, total_target: int) -> None:
    arg = encode([Types.Nat, Types.Nat], [permintaan_id, total_target])
    call_update("createEscrow", arg)


@agen.on_interval(period=60.0)
async def interval_task(ctx):
    if not CANISTER_ID:
        ctx.logger.warning("CANISTER_ID belum di-set. Lewati interval.")
        return
    try:
        groups = group_permintaan(DATA_SIMULASI)
        for g in groups:
            key = f"{g['namaBarang']}::{g.get('lokasi','')}"
            g["id"] = compute_id(key)
            g.setdefault("status", "MENGUMPULKAN")
            tambah_permintaan({
                "id": int(g["id"]),
                "namaBarang": g["namaBarang"],
                "totalKuantitas": int(g["totalKuantitas"]),
                "unit": g["unit"],
                "jumlahPartisipan": int(g["jumlahPartisipan"]),
                "status": g["status"],
            })
            if g["totalKuantitas"] >= 1000 and g["unit"] in ("kg", "liter"):
                tambah_notifikasi(f"Kelompok {g['namaBarang']} di {g.get('lokasi','')} mencapai target. Siap RFQ.")
                create_escrow(int(g["id"]), int(g["totalKuantitas"]))
                tambah_notifikasi(f"Escrow dibuat untuk {g['namaBarang']} total target {g['totalKuantitas']} {g['unit']}")
        ctx.logger.info("Agregasi & update ICP selesai")
    except Exception as e:
        ctx.logger.error(f"Gagal menjalankan interval: {e}")


if __name__ == "__main__":
    print("Menjalankan AgenAgregator. Tekan Ctrl+C untuk berhenti.")
    agen.run()