import { useEffect, useState } from "react";

const CANISTER_ID = process.env.NEXT_PUBLIC_CANISTER_ID;
const IC_HOST = process.env.NEXT_PUBLIC_IC_HOST || "http://127.0.0.1:4943";

async function fetchJSON(path) {
  const url = `${IC_HOST}/?canisterId=${CANISTER_ID}&q=${path}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

export default function PembayaranPage() {
  const [escrow, setEscrow] = useState([]);
  const [error, setError] = useState("");

  async function refreshEscrow() {
    try {
      const data = await fetchJSON("escrow");
      setEscrow(data);
    } catch (e) {
      setError(e.message);
    }
  }

  useEffect(() => {
    refreshEscrow();
    const t = setInterval(refreshEscrow, 15000);
    return () => clearInterval(t);
  }, []);

  function warnManual() {
    alert("Untuk MVP, aksi deposit/konfirmasi dilakukan via dfx call dari WSL.");
  }

  return (
    <div className="mx-auto max-w-3xl p-6">
      <h1 className="text-2xl font-bold">Simulasi Pembayaran (Escrow)</h1>

      <section className="mt-6 rounded-md border bg-white p-4">
        <h2 className="text-lg font-semibold">Aksi</h2>
        <p className="mt-2 text-sm text-gray-700">Contoh perintah WSL:</p>
        <ul className="list-disc pl-6 text-sm text-gray-700">
          <li>Deposit: dfx canister call kawan_umkm_backend deposit '(1, 200)'</li>
          <li>Konfirmasi Barang Diterima: dfx canister call kawan_umkm_backend confirmBarangDiterima '(1)'</li>
        </ul>
        <button onClick={warnManual} className="mt-3 rounded bg-indigo-600 px-4 py-2 text-white">Lakukan Aksi (MVP: via dfx)</button>
      </section>

      <section className="mt-6 rounded-md border bg-white p-4">
        <h2 className="text-lg font-semibold">Status Escrow</h2>
        <div className="mt-3 space-y-3">
          {escrow.map(e => (
            <div key={e.id} className="rounded border p-3">
              <div className="flex items-center justify-between">
                <div className="font-medium">Escrow #{e.id}</div>
                <span className="rounded bg-yellow-50 px-2 py-1 text-xs font-semibold text-yellow-700">{e.status}</span>
              </div>
              <div className="mt-2 text-sm text-gray-700">Permintaan ID: {e.permintaanId}</div>
              <div className="mt-1 text-sm text-gray-700">Target: {e.totalTarget}</div>
              <div className="mt-1 text-sm text-gray-700">Terkumpul: {e.totalTerkumpul}</div>
            </div>
          ))}
        </div>
      </section>

      {error && <p className="mt-4 text-red-600">{error}</p>}
    </div>
  );
}