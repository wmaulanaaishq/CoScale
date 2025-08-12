import { HttpAgent, Actor } from "@dfinity/agent";

const HOST = process.env.NEXT_PUBLIC_ICP_HTTP || "http://127.0.0.1:4943";
const CANISTER_ID = process.env.NEXT_PUBLIC_CANISTER_ID || "";

// Minimal candid for our service
const idlFactory = ({ IDL }) => {
  const Permintaan = IDL.Record({
    id: IDL.Nat,
    namaBarang: IDL.Text,
    totalKuantitas: IDL.Nat,
    unit: IDL.Text,
    jumlahPartisipan: IDL.Nat,
    status: IDL.Text,
  });
  return IDL.Service({
    getPermintaan: IDL.Func([], [IDL.Vec(Permintaan)], ["query"]),
  });
};

export function getBackendActor() {
  if (!CANISTER_ID) return null;
  const agent = new HttpAgent({ host: HOST });
  // In local dev, we need to fetch root key
  if (HOST.includes("127.0.0.1") || HOST.includes("localhost")) {
    agent.fetchRootKey?.().catch(() => {
      console.warn("Tidak bisa fetch root key. Pastikan dfx start berjalan.");
    });
  }
  return Actor.createActor(idlFactory, {
    agent,
    canisterId: CANISTER_ID,
  });
}

export async function fetchPermintaanFromICP() {
  const actor = getBackendActor();
  if (!actor) return [];
  try {
    const res = await actor.getPermintaan();
    return res.map((x) => ({
      id: Number(x.id),
      namaBarang: x.namaBarang,
      totalKuantitas: Number(x.totalKuantitas),
      unit: x.unit,
      jumlahPartisipan: Number(x.jumlahPartisipan),
      status: x.status,
    }));
  } catch (e) {
    console.error("Gagal fetch dari ICP:", e);
    return [];
  }
}