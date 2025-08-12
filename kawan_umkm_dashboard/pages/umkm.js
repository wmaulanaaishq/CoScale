import { useEffect, useState } from "react";

const CANISTER_ID = process.env.NEXT_PUBLIC_CANISTER_ID;
const IC_HOST = process.env.NEXT_PUBLIC_IC_HOST || "http://127.0.0.1:4943";

async function fetchJSON(path) {
  const url = `${IC_HOST}/?canisterId=${CANISTER_ID}&q=${path}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

export default function UmkmPage() {
  const [umkm, setUmkm] = useState({ namaUsaha: "", lokasi: "" });
  const [kebutuhan, setKebutuhan] = useState({ namaBarang: "", kuantitas: 0, unit: "kg", lokasi: "" });
  const [notif, setNotif] = useState([]);
  const [error, setError] = useState("");

  async function refreshNotif() {
    try {
      const data = await fetchJSON("notifikasi");
      setNotif(data);
    } catch (e) {
      setError(e.message);
    }
  }

  useEffect(() => {
    refreshNotif();
    const t = setInterval(refreshNotif, 15000);
    return () => clearInterval(t);
  }, []);

  function warnManual() {
    alert("Untuk MVP, panggilan write (registerUmkm/buatKebutuhan) dilakukan oleh agen atau dfx call. Gunakan dfx canister call dari WSL untuk eksekusi update.");
  }

  return (
    <div className="mx-auto max-w-3xl p-6">
      <h1 className="text-2xl font-bold">UMKM - Pendaftaran & Input Kebutuhan</h1>

      <section className="mt-6 rounded-md border bg-white p-4">
        <h2 className="text-lg font-semibold">Pendaftaran UMKM</h2>
        <div className="mt-3 grid grid-cols-1 gap-3 sm:grid-cols-2">
          <input className="rounded border p-2" placeholder="Nama Usaha" value={umkm.namaUsaha} onChange={e=>setUmkm({...umkm, namaUsaha: e.target.value})} />
          <input className="rounded border p-2" placeholder="Lokasi (kota)" value={umkm.lokasi} onChange={e=>setUmkm({...umkm, lokasi: e.target.value})} />
        </div>
        <button onClick={warnManual} className="mt-3 rounded bg-blue-600 px-4 py-2 text-white">Daftarkan (MVP: via dfx call)</button>
        <p className="mt-2 text-sm text-gray-500">Contoh perintah WSL: dfx canister call kawan_umkm_backend registerUmkm '("Warung Ibu Siti","Bandung")'</p>
      </section>

      <section className="mt-6 rounded-md border bg-white p-4">
        <h2 className="text-lg font-semibold">Input Kebutuhan</h2>
        <div className="mt-3 grid grid-cols-1 gap-3 sm:grid-cols-2">
          <input className="rounded border p-2" placeholder="Nama Barang" value={kebutuhan.namaBarang} onChange={e=>setKebutuhan({...kebutuhan, namaBarang: e.target.value})} />
          <input className="rounded border p-2" placeholder="Kuantitas" type="number" value={kebutuhan.kuantitas} onChange={e=>setKebutuhan({...kebutuhan, kuantitas: Number(e.target.value)})} />
          <select className="rounded border p-2" value={kebutuhan.unit} onChange={e=>setKebutuhan({...kebutuhan, unit: e.target.value})}>
            <option value="kg">kg</option>
            <option value="liter">liter</option>
            <option value="unit">unit</option>
          </select>
          <input className="rounded border p-2" placeholder="Lokasi (kota)" value={kebutuhan.lokasi} onChange={e=>setKebutuhan({...kebutuhan, lokasi: e.target.value})} />
        </div>
        <button onClick={warnManual} className="mt-3 rounded bg-green-600 px-4 py-2 text-white">Kirim (MVP: via agen/dfx)</button>
        <p className="mt-2 text-sm text-gray-500">Contoh perintah WSL: dfx canister call kawan_umkm_backend buatKebutuhan '(1,"Beras",10,"kg","Bandung")'</p>
      </section>

      <section className="mt-6 rounded-md border bg-white p-4">
        <h2 className="text-lg font-semibold">Notifikasi</h2>
        <ul className="mt-3 list-disc pl-5 text-sm">
          {notif.map(n => (
            <li key={n.id}>#{n.id}: {n.pesan}</li>
          ))}
        </ul>
      </section>

      {error && <p className="mt-4 text-red-600">{error}</p>}
    </div>
  );
}