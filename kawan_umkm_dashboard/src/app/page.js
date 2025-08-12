"use client";

import { useEffect, useState } from "react";
import { fetchPermintaanFromICP } from "@/lib/icp";
import KartuPermintaan from "@/components/KartuPermintaan";

const REFRESH_MS = Number(process.env.REFRESH_MS || 30000);

export default function HomePage() {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState([]);

  const load = async () => {
    setLoading(true);
    const res = await fetchPermintaanFromICP();
    setData(res);
    setLoading(false);
  };

  useEffect(() => {
    load();
    const t = setInterval(load, REFRESH_MS);
    return () => clearInterval(t);
  }, []);

  return (
    <main className="mx-auto max-w-4xl p-6">
      <h1 className="text-2xl font-bold">Kawan UMKM - Dashboard</h1>
      <p className="text-sm text-gray-600 mt-1">Menampilkan permintaan kolektif dari ICP canister.</p>

      <div className="mt-6">
        {loading ? (
          <div className="text-gray-500">Memuat data...</div>
        ) : data.length === 0 ? (
          <div className="text-gray-500">Belum ada data.</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {data.map((item) => (
              <KartuPermintaan key={item.id + item.namaBarang} item={item} />)
            )}
          </div>
        )}
      </div>
    </main>
  );
}