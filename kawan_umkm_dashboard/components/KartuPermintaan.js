export default function KartuPermintaan({ item }) {
  const badgeColor = item.status === "SIAP_DIPESAN" ? "bg-green-50 text-green-700" : "bg-blue-50 text-blue-700";
  return (
    <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm transition hover:shadow-md">
      <div className="flex items-start justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">{item.namaBarang}</h3>
          <p className="mt-1 text-sm text-gray-500">Agregasi permintaan kolektif</p>
        </div>
        <span className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-medium ${badgeColor}`}>
          {item.status}
        </span>
      </div>
      <div className="mt-4 grid grid-cols-3 gap-3 text-sm">
        <div className="rounded-lg bg-gray-50 p-3">
          <div className="text-xs text-gray-500">Total Kuantitas</div>
          <div className="mt-1 font-semibold">{item.totalKuantitas} {item.unit}</div>
        </div>
        <div className="rounded-lg bg-gray-50 p-3">
          <div className="text-xs text-gray-500">Partisipan</div>
          <div className="mt-1 font-semibold">{item.jumlahPartisipan}</div>
        </div>
        <div className="rounded-lg bg-gray-50 p-3">
          <div className="text-xs text-gray-500">ID</div>
          <div className="mt-1 font-semibold">{item.id}</div>
        </div>
      </div>
    </div>
  );
}