import os
import time
import itertools
import requests
from collections import defaultdict
from uagents import Agent, Context

from data_simulasi import data_umkm

ICP_BASE_URL = os.getenv("ICP_BASE_URL", "http://127.0.0.1:4943")
CANISTER_ID = os.getenv("CANISTER_ID", "")

# Simple encoder to Candid JSON-like for http interface (icx-proxy expects candid-args in CBOR or candid text for /_/update)
# For local demo, we assume dfx provides http gateway via /api/v2/ endpoints. For simplicity,
# we will rely on dfx's "dfx canister call" command instructions in README for WSL users.
# Here we provide a POST to a custom helper if available; otherwise, this will log a message.

agent = Agent(name="AgenAgregator")


def group_requests(data):
    grouped = defaultdict(lambda: {"namaBarang": "", "totalKuantitas": 0, "unit": "", "jumlahPartisipan": 0})
    for item in data:
        key = (item["barang"], item["unit"])  # group by item and unit
        grouped_item = grouped[key]
        grouped_item["namaBarang"] = item["barang"]
        grouped_item["unit"] = item["unit"]
        grouped_item["totalKuantitas"] += int(item["kuantitas"])  # ensure int
        grouped_item["jumlahPartisipan"] += 1
    # produce list with deterministic ids per run
    result = []
    next_id = 1
    for (_, _), val in grouped.items():
        result.append({
            "id": next_id,
            "namaBarang": val["namaBarang"],
            "totalKuantitas": val["totalKuantitas"],
            "unit": val["unit"],
            "jumlahPartisipan": val["jumlahPartisipan"],
            "status": "MENGUMPULKAN",
        })
        next_id += 1
    return result


def send_to_icp(permintaan):
    if not CANISTER_ID:
        print("[WARN] CANISTER_ID tidak diset. Lewati kirim ke ICP.")
        return False

    # For local demo via dfx http gateway, we can use /api/v2/canister/<id>/call with candid.
    # But encoding candid by hand is non-trivial. In practice, use 'dfx canister call' CLI from WSL.
    # Here, as a placeholder, we attempt a hypothetical local http endpoint if provided by a helper.
    helper_url = os.getenv("ICP_HELPER_URL")
    if helper_url:
        try:
            resp = requests.post(f"{helper_url}/tambahPermintaan", json={"permintaan": permintaan}, timeout=10)
            resp.raise_for_status()
            print(f"[INFO] Terkirim via helper: {permintaan['namaBarang']} -> {resp.text}")
            return True
        except Exception as e:
            print(f"[ERROR] Gagal kirim ke helper ICP: {e}")
            return False

    # Fallback: log curl command for WSL usage
    print("[INFO] Jalankan dari WSL untuk kirim ke ICP menggunakan dfx CLI:")
    candid_arg = (
        f"record {{ id = {permintaan['id']}: nat; namaBarang = \"{permintaan['namaBarang']}\"; "
        f"totalKuantitas = {permintaan['totalKuantitas']}: nat; unit = \"{permintaan['unit']}\"; "
        f"jumlahPartisipan = {permintaan['jumlahPartisipan']}: nat; status = \"{permintaan['status']}\" }}"
    )
    print(
        f"dfx canister call {CANISTER_ID} tambahPermintaan '( {candid_arg} )'"
    )
    return True


@agent.on_interval(period=60.0)
async def aggregate_and_send(ctx: Context):
    ctx.logger.info("Menjalankan agregasi permintaan UMKM...")
    grouped = group_requests(data_umkm)
    for p in grouped:
        send_to_icp(p)
    ctx.logger.info(f"{len(grouped)} permintaan agregat diproses.")


if __name__ == "__main__":
    from uagents.setup import fund_agent_if_low

    fund_agent_if_low(agent.wallet.address())
    agent.run()