import { useEffect, useState } from "react";
import Link from "next/link";
import KartuPermintaan from "../components/KartuPermintaan";
import SkeletonCards from "../components/SkeletonCards";

const CANISTER_ID = process.env.NEXT_PUBLIC_CANISTER_ID;
const IC_HOST = process.env.NEXT_PUBLIC_IC_HOST || "http://127.0.0.1:4943";

export default function HomePage() {
  const [items, setItems] = useState([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  async function fetchPermintaan() {
    if (!CANISTER_ID) {
      setError("NEXT_PUBLIC_CANISTER_ID belum di-set");
      setLoading(false);
      return;
    }
    try {
      const url = `${IC_HOST}/?canisterId=${CANISTER_ID}&q=permintaan`;
      const res = await fetch(url);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setItems(data);
      setError("");
    } catch (e) {
      setError(`Gagal mengambil data: ${e.message}`);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchPermintaan();
    const t = setInterval(fetchPermintaan, 30000);
    return () => clearInterval(t);
  }, []);

  return (
    <div>
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Dasbor Permintaan Kolektif</h1>
        <div className="space-x-3 text-sm">
          <Link className="text-blue-600 hover:underline" href="/umkm">UMKM</Link>
          <Link className="text-blue-600 hover:underline" href="/pembayaran">Pembayaran</Link>
        </div>
      </div>
      {loading && (
        <div className="mt-6">
          <SkeletonCards count={4} />
        </div>
      )}
      {error && <p className="mt-4 text-red-600">{error}</p>}
      {!loading && !error && (
        <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2">
          {items.map((item) => (
            <KartuPermintaan key={item.id} item={item} />
          ))}
        </div>
      )}
    </div>
  );
}